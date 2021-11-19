# Wttj Backend Technical Assessment Test

This is the project created for the backend technical assessment test for
Welcome to the Jungle.

This projects uses Erlang/Elixir with the following version:

- Erlang/OTP 24
- Elixir 1.12.2


## Installation

Install dependencies.

```sh
; mix deps.get
```

Run tests.

```sh
; mix test
```

Run `mix docs` to read this file and the project’s documentation.

## First Exercise: Print a Table

To run the first exercise, run the following commands:

```sh
; mix escript.build
; ./jobs_worldwide
```

I started to implement a CSV parser but I quickly realised that there were
string fields with commas. I wanted to create a CSV parser from scratch myself
since the CSV files are well-known, but I realized that it may not be the
fastest way to deal with larger streams, that I may not know what kind of data I
may get in the future. So I decided to use an external library for the task.  
Both [NimbleCSV](https://hexdocs.pm/nimble_csv/) and
[CSV](https://hexdocs.pm/nimble_csv/) handle RFC4180, but I went with NimbleCSV
since the community support is stronger. Moreover, NimbleCSV is maintened by
Dashbit, a company where José Valim is involved.

To get a continent from a coordinate point, I used areas described in this
[Stack Overflow](https://stackoverflow.com/a/25075832) thread. We could have
used a library that makes call to an external API like Google Maps, or Open
Stree Map, but it may be a slow method that can be rate limited.  
This approach have some caveats as well: the map is not precise at all (Papua
New Guinea and New Zealand are missing for example), you can’t easily guess if
your area is correct if you decide to expand/add zones yourself.  
I was looking for a simple geometry library that could tell if a point is within
a specified area. I stumbled on [Geo](https://github.com/bryanjos/geo) but it
didn’t quite meet the requirements. Its README mentions
[topo](https://github.com/pkinney/topo) which fills my needs.

To get the matching profession category from a job offer, I decided to switch
the ID to its matching profession in a new list rather than doing dynamic
matching at the visualization phase.

Finally, to output the table, I used another library,
[TableRex](https://github.com/djm/table_rex), to easily get a visualization.


## Second Exercise: Scaling?

The previous assignement was dealing with 5,069 job offers from a CSV file. But
if we ever had to deal with a database of 100,000,000 jobs offers with 1,000 new
offers per seconds, it would make sense to work from something else than a CSV
file on a filesystem!

A good starter would be to store the offers in a database like PostgreSQL for
permanent storage of the initial set of offers and the incoming stream of
offers. But how can we output the table in real-time with a constant database
growth?

Doing the calculation for the full database each seconds would be a waste of
time and resources. The number of requests from the client also matters.

Rather than doing the full database recomputation, it would be easier to store
the current state of the client in a cache, and only recalculate new offers. To
keep the operation live, we could combine everything in such a chain:  
Server&nbsp;&rarr;&nbsp;Websocket&nbsp;&rarr;&nbsp;Redis&nbsp;&rarr;&nbsp;SPA

The websocket would do the actual work of getting the informations from the
server, keeping the state from the client, and sending data back and forth.
Redis would act as a buffer to store the state of the socket, keeping it alive
if the client reloads the page. The single page application *raison d’être* is
to keep the socket connexion alive if the user have to change the application
context (going from the main application to the settings or billing page, etc.).

It could be optimized by having a cluster of Redis instances to handle a lot of
clients around the world.

The nature of transported messages can be optimized, but more on that on the
third assignement.


## Third exercise

To have this data consumable by an API, we have to choose what kind of clients
we are going to deal with. There are two cases:

- An API for third parties.
- An API for the frontend.

For the first case, a REST or a GraphQL API sending JSON to the client may be a
good solution that people would be familiar with.

For the front-end, we could transmit binaries for lighter messages and faster
parsing. Since we are in the Erlang world, we are lucky to have such a format
built-in: the Erlang External Term Format (ETF) fits very well our needs.
Indeed, if we are working end-to-end with Elixir, we don’t have to encode and
decode our messages in an alien format, saving processing time.

Both scenarios are handled this way by companies like Discord: A Rest API
transmitting JSON or ETF is open for developpers, and the official client uses a
websocket and ETF for performance. We can still use ETF with a JavaScript
front-end to only have the encoding/decoding part from one side only:
https://github.com/discord/erlpack

As for the endpoints, the first assignement data sources gave a good clue. We
can have a endpoint to query for a list of offers for a specific profession
category, or we could query for all offers.


## Encountered Issues

- To keep this application fast, we had to rely on hardcoded coordinates for
  continents. I traded a true geography library for a geometry library.
- CSVs have multiple conventions and a RFC (different separators, multiple
  line-endings, string escaping, etc.). To keep the code simple and
  reliable, I used an external library. We know how to parse files in `data/`
  but what if we use this app to import unknown CSV files from a client? The
  NimbleCSV library can handle that with little efforts.
- Data structures. That was a lot to learn in a few days (I barely wrote any
  Elixir before). For example, how data structures are (not) related to logic:
  Elixir/functional programming quirks went in the way at first but it was
  enventually trivial to overcome, considering how the assignement was a very
  specific task. 

## Why Elixir?

I had a Ruby training and I’m familiar with Go. I only wrote very trivial Elixir
IO code in the past, without using any data structure. Yet, I chose to use
Elixir for this test because I’m curious about functional programming, and about
the Erlang virtual machine in particular. It’s also one of the langage used at
Welcome to the Jungle, so I wanted to grasp how it felt to program with Elixir.

The test took more time because I had to learn Elixir while tackling the test,
but it was worthy of my time, what an enjoyable experience! The shipped `mix`
build and test tools is enjoyable to use. It even ships a test tool and a
documentation generator! Overall, Elixir have very modern features.


## Some Final Notes

I worked from the `dev` branch and squashed commits together before merging with
`main` to get a cleaner history.
