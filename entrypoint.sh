#!/bin/bash
while ! pg_isready -q -h $PG_HOST -p $PG_PORT -U $PG_USERNAME
do
	echo "$(date) - waiting database start"
	sleep 1
done

if [[ -z `psql -Atqc "\\list $PG_DATABASE"` ]]; then
	echo "database $PG_DATABASE doesnt exist. Creating..."
	createdb -E UTF8 $PG_DATABASE -l en_US.UTF-8 -T template0
	mix ecto.migrate
	mix run priv/repo/seeds.exs
	echo "database $PG_DATABASE created"
fi

exec mix phx.server
