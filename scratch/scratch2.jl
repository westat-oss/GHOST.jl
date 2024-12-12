using GHOST
using DataFrames: DataFrames, AbstractDataFrame, DataFrame, order, groupby, select, leftjoin, nrow, rename, subset, sort
using Tables: ByRow
using Diana: Diana, HTTP, Client, GraphQLClient, Result,
             # HTTP
             HTTP.request, HTTP.ExceptionRequest.StatusError
using Distributed: addprocs, @everywhere, fetch, @spawnat, workers, remotecall, remotecall_eval, Future, @sync, @distributed
using JSON3: JSON3
using LibPQ: LibPQ, Connection, execute, load!,
             # Intervals
             Intervals, Interval, superset, Closed, Open,
             # TimeZones
             TimeZones, TimeZone, ZonedDateTime, UTC, TimeZones.utc_tz,
             # Dates
             Dates, DateTime, Dates.CompoundPeriod, Dates.canonicalize, Second, Year, Month, Week, Dates.format, now, unix2datetime, Day, Date, Hour, year, Minute,
             # Tables
             Tables, rowtable
import Base: show, summary, isless

setup_high_prio(high_permission = true)
(;conn, schema, pat) = GHOST.PARALLELENABLER

user_groups = DataFrame(execute(conn, """SELECT EXTRACT(year from createdat) as usr_yr, count(*)
                FROM $schema.users A
                LEFT JOIN $schema.test_usr B
                ON A.author_id = B.id
                WHERE NOT B.id is null 
                AND acctype = 'User'
                and updatedat IS NULL GROUP BY EXTRACT(year from createdat);"""))

