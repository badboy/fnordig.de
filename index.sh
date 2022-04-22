#!/bin/bash

set -e

DATABASE_PATH="${DATABASE_PATH:-blog.db}"
sqlite3 -batch -bail "$DATABASE_PATH" "
CREATE TABLE IF NOT EXISTS [posts] (
   [_id] TEXT PRIMARY KEY,
   [_path] TEXT,
   [text] TEXT,
   [html] TEXT,
   [permalink] TEXT,
   [title] TEXT,
   [published_date] TEXT,
   [layout] TEXT,
   [data] TEXT,
   [excerpt] TEXT
);
PRAGMA journal_mode = WAL;
PRAGMA foreign_keys = ON;
" >/dev/null

markdown-to-sqlite "$DATABASE_PATH" posts _posts/*

sqlite-utils convert "$DATABASE_PATH" posts text '
from markdown import Markdown
import io

__md = None

def define():
    global __md
    def unmark_element(element, stream=None):
        global io
        if stream is None:
            stream = io.StringIO()
        if element.text:
            stream.write(element.text)
        for sub in element:
            unmark_element(sub, stream)
        if element.tail:
            stream.write(element.tail)
        return stream.getvalue()

    Markdown.output_formats["plain"] = unmark_element
    __md = Markdown(output_format="plain")
    __md.stripTopLevelTags = False

define()

def convert(text):
    global __md
    return __md.convert(text)
'

sqlite-utils enable-fts --fts5 "$DATABASE_PATH" posts title text 2>/dev/null || true
sqlite-utils rebuild-fts "$DATABASE_PATH" posts
