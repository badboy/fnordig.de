permalink: "/{{ year }}/{{ month }}/{{ day }}/u2f-demo-application"
title: U2F demo application
published_date: "2015-03-06 16:07:00 +0100"
layout: post.liquid
data:
  route: blog
---
Two weeks ago I got my first Universal Second Factor Device.
It's an inexpensive small USB key: the [FIDO U2F Security Key][fido-key].
This key can be used as a 2nd Factor Authentication device.

It uses the [protocol as specified by the FIDO Alliance][u2f-overview], which consists of Google, Microsoft, Yubico, Lenovo and others.

## What it provides

The overview document states:

> The FIDO U2F protocol enables relying parties to offer a strong cryptographic 2nd factor option for end user security.

After the user has registered their device, the application can request authentication using this key on login (or when it seems necessary, e.g. when changing some other security settings).

Right now it relies on a extension for Chrome to provide the JavaScript API: [FIDO U2F (Universal 2nd Factor) extension][chrome-addon].
Hopefully this will soon be implemented directly in the browser.

## How it works

The U2F protocol is not complex at all, making it easy to implement and verify its correctness.
It consists of 2 phases: registration and autentication, both requiring explicit human interaction.

### Registration

1. The server choses a pseudo-random 32 byte *challenge*
2. It sends this challenge, a version identifier and its `appId` to the browser
3. The browser forwards this data and the origin of the challenge to the key after requesting access requiring human interaction
4. The key assembles its public key, key handle and a signature. The signature includes the seen `appId`, a hash of the provided challenge and origin, its own public key and its key handle.
5. The browser sends back this registration data to the server, where the certificate is checked, the signature validated and public key and key handle are saved.

The key is now registered for use with this origin and appId.

### Authentication

1. The server choses a pseudo-random 32 byte *challenge* for every possible key handle.
2. This data is sent to the browser, including the `appId`
3. The browser forwards this data to the key, including the origin
4. The key is activated by human interaction, it then creates a signature of a hash of the `appId`, a counter value and a hash of the provided challenge and origin. This signature and the counter value is sent back to the browser, which submits it to the server
5. The server verifies the signature using the previously saved public key and verifies that the counter value is larger than any previously seen counter for this key handle.

If all runs through the user is successfully authenticated based on his key.

## The implementation

The small demo application does nothing more than authenticating a user by name and a password and authorizing access to the private section of the website.
A user is then able to add second factor authentication through U2F devices by registering one or more keys for their account.
If a user has U2F devices registered, the server requires additional authentication by providing the U2F key to the website,

I decided to built this small application using the [Cuba][] framework, a small Rack-based web framework providing only the absolute basics necessary for this.
Authentication is handled by [Shield][], user data is stored using [Ohm][].
For correct generation and verification of the U2F data I rely on [ruby-u2f][ruby-u2f], an implementation of the full specification.
The code itself is quite small, there are some todos and unimplemented things still open, but from what I understand right now they are not security-impacting.
But before you run this in production, please take your own measurement and check the implementation against the spec.

The following will only describe the U2F relevant parts. The rest should be straight forward.

### Key registration

Before a user can use second factor authentication, they need to [register their device with the service](https://github.com/badboy/cuba-u2f-demo/blob/master/app.rb#L137-L148).

~~~ruby
on get do
  registration_requests = u2f.registration_requests
  session[:challenges] = registration_requests.map(&:challenge)

  render "key_add",
    registration_requests: registration_requests
end
~~~

First we generate registration requests for the key to sign later.
We then need to save the provided challenges into the session to be able to check them later again.
These could also be saved directly into a database.
We could also add sign requests for known key handles to later check if the key is already known, but for simplicity we don't do this here.

Then we simply render our form, the [important JavaScript part](https://github.com/badboy/cuba-u2f-demo/blob/master/views/key_add.mote#L18-L36) in the frontend is this:

~~~javascript
{% raw %}var registerRequests = {{ registration_requests.to_json }};{% endraw %}
var signRequests = [];

u2f.register(registerRequests, signRequests, function(registerResponse) {
    var form, reg;

    if (registerResponse.errorCode) {
        return alert("Registration error: " + registerResponse.errorCode);
    }

    form = document.forms[0];
    response = document.querySelector("[name=response]");

    response.value = JSON.stringify(registerResponse);

    form.submit();
});
~~~

First we pass in the register and sign requests as JSON to be inspected by JavaScript.
We then call the u2f API provided by the browser (for now added by an extension).
The browser handles all the complicated stuff of verifying the provided request, asking for the user's permission to use the key, sending it to the key and returning back the signed data to the browser.
Once this is done, the callback is called. All that's left to do is sending this data back to the server. We use a simple hidden form for that.

On the server side the data is parsed and verified. Again, this is handled completely by the library. [All we need to do](https://github.com/badboy/cuba-u2f-demo/blob/master/app.rb#L114-L135) is calling the right methods and saving the key handle and public key to our database.

~~~ruby
on post, param("response") do |response|
  u2f_response = U2F::RegisterResponse.load_from_json(response)

  reg = begin
          u2f.register!(session[:challenges], u2f_response)
        rescue U2F::Error => e
          session[:error] =  "Unable to register: #{e.class.name}"
          redirect "/private/keys/add"
        ensure
          session.delete(:challenges)
        end

  Registration.create(:certificate => reg.certificate,
                      :key_handle  => reg.key_handle,
                      :public_key  => reg.public_key,
                      :counter     => reg.counter,
                      :user        => current_user)

  session[:success] = "Key added."
  redirect "/private/keys"
end
~~~

The user has now a registered U2F key and must provide this on the next login to be successfully authenticated.

## Second Factor authentication

A user with a registered U2F device first needs to login using [the usual way](https://github.com/badboy/cuba-u2f-demo/blob/master/app.rb#L236-L252) by providing a username and the password.

~~~ruby
if login(User, username, password)
  if current_user.registrations.size > 0
    session[:notice] = "Please insert one of your registered keys to proceed."
    session[:user_prelogin] = current_user.id
    logout(User)
    redirect "/login/key"
  end

  # …
end
~~~

If the provided login data is correct and the user has U2F devices registered, we redirect him to the next page handling this.

In this second login step, we [generate a sign request on the server](https://github.com/badboy/cuba-u2f-demo/blob/master/app.rb#L172-L193):

~~~ruby
# Fetch existing Registrations from your db
key_handles = user.registrations.map(&:key_handle)
if key_handles.empty?
  session[:notice] = "Please add a key first."
  redirect "/private/keys"
end

# Generate SignRequests
sign_requests = u2f.authentication_requests(key_handles)
~~~

and [provide it to the user](https://github.com/badboy/cuba-u2f-demo/blob/master/views/login_key.mote#L15-L32):

~~~javascript
{% raw %}var signRequests = {{ sign_requests.to_json }};{% endraw %}

u2f.sign(signRequests, function(signResponse) {
    var form, reg;

    if (signResponse.errorCode) {
        return alert("Authentication error: " + signResponse.errorCode);
    }

    form = document.forms[0];
    response = document.querySelector("[name=response]");

    response.value = JSON.stringify(signResponse);

    form.submit();
});
~~~

Again, we simply pass on this data to the browser API, which makes sure the device is actually present and then lets the key sign the provided data.
Once it returns we then send on this data to the server.

If there is an error in the signing process we just alert the user for now. For a better user experience this should be handled more nicely, showing the user a proper error message and giving the option to try again.

[On the server side](https://github.com/badboy/cuba-u2f-demo/blob/master/app.rb#L195-L227) we need to check that the key handle exists for the user, then let the library validate the signed authentication request against our previously saved challenge.
If everything checks out fine, we can finally login the user and set the session.
As the last step we're also updating the saved counter for the given key handle. This way we can protect against reply attacks. New authentications are only valid if the sent counter is higher than our saved one.

~~~ruby
u2f_response = U2F::SignResponse.load_from_json(response)

registration = user.registrations.find(key_handle: u2f_response.key_handle).first

unless registration
  session[:error] = "No matching key handle found."
  redirect "/login"
end

begin
  u2f.authenticate!(session[:challenges], u2f_response,
                    Base64.decode64(registration.public_key), registration.counter.to_i)

rescue U2F::Error => e
  session[:error] = "There was an error authenticating you: #{e}"
  redirect "/login"
ensure
  session.delete(:challenges)
end

authenticate(user)
registration.counter = u2f_response.counter
registration.save
~~~

And that's it. That's all it takes for a working U2F implementation.

<center><img src="//tmp.fnordig.de/cuba-u2f-demo.gif"></center>

(what's not visible: the browser asks for permission to use the U2F key on registration and the simple key is only usable for a short time after insertion, so it needs to be reinserted for each login, requiring explicit human interaction)

The full code is available in the repository on GitHub: [cuba-u2f-demo](https://github.com/badboy/cuba-u2f-demo)

---

Thanks to [@soveran](https://twitter.com/soveran) for proof-reading a draft of this post and of course for his work on Cuba.


[cuba]: https://github.com/soveran/cuba
[ruby-u2f]: https://github.com/castle/ruby-u2f
[fido-key]: http://www.amazon.de/dp/B00OGPO3ZS
[u2f-overview]: http://fidoalliance.org/specs/fido-u2f-v1.0-ps-20141009/fido-u2f-overview-ps-20141009.html
[dep]: https://github.com/cyx/dep
[chrome-addon]: https://chrome.google.com/webstore/detail/fido-u2f-universal-2nd-fa/pfboblefjcgdjicmnffhdgionmgcdmne
[shield]: https://github.com/cyx/shield
[ohm]: https://github.com/soveran/ohm
