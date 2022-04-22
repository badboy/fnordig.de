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
sqlite-utils enable-fts --fts5 "$DATABASE_PATH" posts title text 2>/dev/null || true
sqlite-utils rebuild-fts "$DATABASE_PATH" posts
