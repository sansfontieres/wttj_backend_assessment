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




<!-- Placeholder
## Third exercise
--> 

## Encountered Issues

- I barely wrote any Elixir before, so I had to get familiar with its data
  structures. Thakfully, the Elixir documentation is easy to parse.
- To keep this application fast, we had to rely on hardcoded coordinates for
  continents. I traded a true geography library for a geometry library.
- CSVs have multiple conventions and a RFC (different separators, multiple
  line-endings, string escaping, etc.). To keep the code simple and
  reliable, I used an external library. We know how to parse files in `data/`
  but what if we use this app to import unknown CSV files from a client? The
  NimbleCSV library can handle that with little efforts.
- Data structures. That was a lot to learn in a few days alongside Elixir
  quirks.

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
