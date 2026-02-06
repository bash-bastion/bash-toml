# Specification

Toml Subset (Derived from TOML v1.0.0)

## Objectives

- _No changes_

## Spec

- _No changes_

## Comment

- _No changes_

## Key/Value Pair

The types of values have been constrained to only

- String
- Integer
- Array

Things like float, local date, inline table, etc. are invalid

## Keys

The types of keys have been constrained to only

- Bare keys

Things like quoted, dotted, etc. keys are invalid

## Strings

The types of strings have been constrained to only

- Literal

Things like basic, multi-line basic, multi-line literal, etc. are invalid

Note that for convenience, literal strings _can_ be surrounded by single quotes. Of course, any escape sequences within the value will not be evaluated

## Integers

The types of integers have been constrained to only decimal (without any sign-denoting prefix)

Things like `+99`, `1_000`, `0xFF`, etc. are all invalid

## Float

Floats are invalid

## Boolean

Booleans are invalid

## Offset Date-Time

Offset date-times are invalid

## Local Date-Time

Local date-times are invalid

## Local Date

Local dates are invalid

## Local Time

Local times are invalid

## Array

Additional constraints include

- Arrays cannot be nested
- Values of different types cannot be mixed
- Strings within arrays cannot include the character `,`

## Table

- _No changes_

## Inline Tables

Inline tables are invalid

## Array of Tables

Array of tables are invalid

## Filename Extension

- _No changes_

## MIME Type

- _No changes_

## ABNF Grammar

- _No changes_
