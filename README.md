# Wttj Backend Technical Assessment Test

This is the project created for the backend technical assessment test for
Welcome to the Jungle.

This project uses Erlang/Elixir with the following version:

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

I started to implement a CSV parser, but I quickly realized that there were
fields to escape because they contained commas. I wanted to create a CSV parser
from scratch myself since the CSV files are well-known, but I realized that it
may not be the fastest way to deal with larger streams, that I may not know what
kind of data I may get in the future. So I decided to use an external library
for the task.  
Both [NimbleCSV](https://hexdocs.pm/nimble_csv/) and
[CSV](https://hexdocs.pm/nimble_csv/) handle RFC4180, but I went with NimbleCSV
since the community support is stronger. Moreover, NimbleCSV is maintained by
Dashbit, a company where José Valim is involved.

To get a continent from a coordinate point, I used areas described in this
[Stack Overflow](https://stackoverflow.com/a/25075832) thread. We could have
used a library that makes call to an external API like Google Maps, or Open
Street Map, but it may be a slow method that can be rate limited.  
This approach has some caveats as well: the map is not precise at all (Papua
New Guinea and New Zealand are missing for example), you can’t easily guess if
your area is correct if you decide to expand/add zones yourself.  
I was looking for a simple geometry library that could tell if a point is within
a specified area. I stumbled on [Geo](https://github.com/bryanjos/geo), but it
didn’t quite meet the requirements. Its README mentions
[topo](https://github.com/pkinney/topo) which fills my needs.

To get the matching profession category from a job offer, I decided to switch
the ID to its matching profession in a new list rather than doing dynamic
matching at the visualization phase.

Finally, to output the table, I used another library,
[TableRex](https://github.com/djm/table_rex), to easily get a visualization.


## Second Exercise: Scaling?

The previous assignment was dealing with 5,069 job offers from a CSV file. But
if we ever had to deal with a database of 100,000,000 jobs offers with 1,000 new
offers per seconds, it would make sense to work from something else than a CSV
file on a filesystem!

A good starter would be to store the offers in a database like PostgreSQL for
permanent storage of the initial set of offers, and the incoming stream of
offers as well.  Moreover, each offer would get an identifier assigned to it.
But how can we output the table in real-time with a constant database growth?

Doing the calculation for the full database each second would be a waste of
time and resources. The number of requests from the client also matters.

Rather than doing the full database recomputation, it would be easier to store
the current state of the client in a cache, and only recalculate new offers. To
keep the operation live, we could combine everything in such a chain:  
Server&nbsp;&rarr;&nbsp;Websocket&nbsp;&rarr;&nbsp;Redis&nbsp;&rarr;&nbsp;SPA

- The websocket would do the actual work of getting the information from the
  server, keeping the state from the client, and sending data back and forth.
- Redis would act as a buffer to store the state of the socket, keeping it alive
  if the client reloads the page.
- The single page application *raison d’être* is to keep the socket connection
  alive if the user have to change the application context (going from the main
  application to the settings or billing page, etc.).

All of this could be optimized by having a cluster of Redis instances to handle
a lot of clients around the world.

Another improvement would be to use a lower-level language through a NIF to
benefit from their superior speed for the business logic, while the Elixir
application takes care of the network part. A good choice would be Rust through
[Rustler](https://github.com/rusterlium/rustler). Zig through
[Zigler](https://github.com/ityonemo/zigler) would be interesting considering
how good Zig is with data, but the language is pre 1.0.0, so it’s not
production-ready.  

NIF or not, we could further optimize the massive amount of data flow by
using multiple processes, effectively parallelizing the computation and avoiding
throttling. Thanks, BEAM!

Finally, the nature of transported messages can be optimized, but more on that on the
third assignment.


## Third Exercise

To have this data consumable by an API, we have to choose what kind of clients
we are going to deal with. There are two cases:

- An API for third parties.
- An internal API.

For the first case, a REST or a GraphQL API sending JSON to the client may be a
good solution that people would be familiar with.

For the internal API, we could transmit binaries for lighter messages and faster
parsing. Since we are in the Erlang world, we are lucky to have such a format
built-in: the Erlang External Term Format (ETF) fits very well our needs.
Indeed, if we are working end-to-end with Elixir, we don’t have to encode and
decode our messages in an alien format, saving processing time and data
structure manipulation.

Both scenarios are handled this way by companies like Discord:
- A Rest API transmitting JSON or ETF is open for developers
- The official client uses a websocket and ETF for performance.

We can still use ETF with a JavaScript front-end to only have the
encoding/decoding part from one side only:
https://github.com/discord/erlpack

**N.B.** (De)serialization from binaries is faster in theory. In the real world,
we would have to benchmark to check if the kind of message transmitted would be
better transmitted in a plain-text JSON or in a binary format as ETF, keeping
scaling in mind.

### Back to the Implementation

For this exercise, I implemented a minimal implementation that transmit either
an ETF or a JSON file on request. I used
[Plug.Cowboy](https://github.com/elixir-plug/plug_cowboy) for the webserver. We
could have used Phoenix with all its niceties, but a simpler server is good
enough for our minimal implementation.  
I also used [PlugEtf](https://github.com/scarfacedeb/plug_etf) to handle the ETF
parsing. This library is not maintained, but it is very simple because it only
accommodates a binding between the Erlang built-in functions
`:erlang.term_to_binary`/`:erlang.binary_to_term` and Plug’s paradigm. In a
perfect world, a developer would have written this themselves (like hex.pm does,
for example), but I lack the time to do this for the exercise. For a more
traditional experience, I also used
[Jason](https://github.com/michalmuskala/jason) to generate JSON messages.

I decided to create a new function in the `CSVParser` module to get a list with
more information (`[continent, contract, name, category]`). Doing so, we have
more valuable data to share through the API, rather than the preprocessed list
for the table of the first exercise.

As for the endpoints, the first assignment data sources gave a good starting
clue. We can send a query to filter a list of offers for a specific profession
category, or we could query for all offers.

From there, I created an endpoint at http://localhost:3000/offers/ with the
following filters:

- The kind of contract (full-time, internship, etc.)
- The continent of the office
- The category of the profession

Filters can be queried as such:
http://localhost:3000/offers/continent=Europe&category=Tech&contract=full_time


### Usage

To launch the server, run

```sh
; mix run --no-halt
```

From another terminal window, you can send your query like this:

```sh
# For a JSON message
; curl -s "http://localhost:3000/offers/continent=Océanie"
[{"category":"retail","continent":"océanie","contract":"full_time","name":"[TAG Heuer Australia] Boutique Manager - Melbourne"}]

# For an ETF message
# Using a buffer file in /tmp because the filesystem may not handle piping the binary
; curl -s -H "accept: application/x-erlang-binary" "http://localhost:3000/offers/continent=Océanie" -o /tmp/offers
; cat /tmp/offers | elixir -e "IO.read(:stdio, :all) |> :erlang.binary_to_term() |> IO.inspect()"
[
  %{
    category: :retail,
    continent: :océanie,
    contract: :full_time,
    name: "[TAG Heuer Australia] Boutique Manager - Melbourne"
  }
]
```


## Some Final Notes

I worked from the `dev` branch and squashed commits together before merging with
`main` to get a cleaner history.


### Encountered Issues

- To keep this application fast, we had to rely on hardcoded coordinates of the
  seven continents. I traded a true geography library for a geometry library.
- CSVs have multiple conventions and a RFC (different separators, multiple
  line-endings, string escaping, etc.). To keep the code simple and
  reliable, I used an external library. We know how to parse files in `data/`
  but what if we use this application to import unknown CSV files from a client?
  The NimbleCSV library can handle that with little efforts.
- Data structures. That was a lot to learn in a few days (I barely wrote any
  Elixir before). For example, how data structures are (not) related to logic:
  Elixir/functional programming quirks went in the way at first, but it was
  eventually trivial to overcome, considering how the assignments were very
  specific tasks. 


### Why Elixir?

I had a Ruby training, and I’m familiar with Go. I only wrote very trivial
Elixir IO code in the past, without using any data structure. Yet, I chose to
use Elixir for this test because I’m curious about functional programming, and
about the Erlang virtual machine in particular. It’s also one of the language
used at Welcome to the Jungle, so I wanted to grasp how it feels to program with
Elixir.

The test took more time because I had to learn Elixir while tackling the test,
but it was worthy of my time, what an enjoyable experience! The `mix` build and
test tools are enjoyable to use. It even ships a documentation generator and
some kind of typespec checker! Overall, Elixir have very modern features and
seems easy to catch on.

<br />
<br />

—  
Cheers!  
Romain Hervier
