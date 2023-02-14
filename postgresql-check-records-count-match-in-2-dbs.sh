RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
red() {
    echo -e "${RED}${@}${NC}"
}
green(){
    echo -e "${GREEN}${@}${NC}"
}

# Allows read tables list from cli. Will verify only these tables
# Example: 
#> bash postgresql-check-records-count-match-in-2-dbs.sh table1 table2
tables="$@"

PASS='' # database password. In this case it is similar for both databases 

SRC_HOST=''
DST_HOST=''

schema="public"
# schema='other'

echo "Schema: $schema"

tables_count_src=$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $SRC_HOST -t -c "SELECT count(table_name) FROM information_schema.tables WHERE table_type = 'BASE TABLE' and table_schema='$schema';")
tables_count_dst=$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $DST_HOST -t -c "SELECT count(table_name) FROM information_schema.tables WHERE table_type = 'BASE TABLE' and table_schema='$schema';")

echo Tables count: $tables_count_src, $tables_count_dst

if [[ "$tables_count_dst" != "$tables_count_src" ]]; then
    red "tables count do not match"
    exit 1
fi

if [ "$#" -eq "0" ]; then
    tables="$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $SRC_HOST -t -c "SELECT table_name FROM information_schema.tables WHERE table_type = 'BASE TABLE' and table_schema='$schema';")"
fi

fail="false"
failed_tables=""
counter=1
for table in $tables; do
    echo "($counter/$tables_count_src) $table: "
    src_records_count=$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $SRC_HOST -t -c "SELECT count(*) FROM $schema.$table ;")
    echo -n "$src_records_count"
    dst_records_count=$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $DST_HOST -t -c "SELECT count(*) FROM $schema.$table ;")
    echo "$dst_records_count"

    if [[ "$src_records_count" == "$dst_records_count" ]]; then
        green OK
    else
        red ERROR
        # exit 1
        fail="true"
        failed_tables="$table $failed_tables"
    fi
    (( counter = counter+1 ))
done

if [[ "$fail" == "true" ]]; then
    red "tables did not match: $failed_tables"
fi
