RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'
red() {
    echo -e "${RED}${@}${NC}"
}
green(){
    echo -e "${GREEN}${@}${NC}"
}

tables="$@"

PASS=''
SRC_HOST=''
DST_HOST=''


schema="public"

echo "Schema: $schema"

tables_count_src=$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $SRC_HOST -t -c "SELECT count(table_name) FROM information_schema.tables WHERE table_type = 'BASE TABLE' and table_schema='$schema';")
tables_count_dst=$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $DST_HOST -t -c "SELECT count(table_name) FROM information_schema.tables WHERE table_type = 'BASE TABLE' and table_schema='$schema';")

echo Tables count: $tables_count_src, $tables_count_dst

if (( "$tables_count_dst" != "$tables_count_src" )); then
    red "tables count do not match"
    exit 1
fi

if (( "$#" == "0" )); then
    tables="$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $SRC_HOST -t -c "SELECT table_name FROM information_schema.tables WHERE table_type = 'BASE TABLE' and table_schema='$schema' ORDER BY table_name;")"
fi

fail="false"
failed_tables=""
counter=1
for table in $tables; do
    echo -n "($counter/$tables_count_src) $table: "
    src_records_count=$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $SRC_HOST -t -c "SELECT count(*) FROM $schema.$table ;")
    # src_records_count="0"
    echo -n "$src_records_count, "
    dst_records_count=$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $DST_HOST -t -c "SELECT count(*) FROM $schema.$table ;")
    echo -n "$dst_records_count - "

    if (( "$src_records_count" == "$dst_records_count" )); then
        green OK
        
        # # CHECKSUM
        # https://www.cybertec-postgresql.com/en/postgresql-creating-checksums-for-tables/
        #
        # echo -n "Checksum: src - "
        # md5_src=$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $SRC_HOST -t -c "SELECT md5_agg() WITHIN GROUP (ORDER BY $table) FROM $table;")
        # echo -n "$md5_src"
        # echo -n ", dst - "
        # md5_dst=$(PGPASSWORD=$PASS psql -U postgres -d postgres -h $DST_HOST -t -c "SELECT md5_agg() WITHIN GROUP (ORDER BY $table) FROM $table;")
        # echo -n "$md5_dst - "
        # if [[ "$md5_src" == "$md5_dst" ]]; then
        #     green OK
        # else
        #     red ERROR
        #     fail="true"
        #     failed_tables="$table $failed_tables"
        # fi
        # # CHECKSUM
    else
        red ERROR
        fail="true"
        failed_tables="$table $failed_tables"
    fi
    (( counter = counter+1 ))
done

if [[ "$fail" == "true" ]]; then
    red "tables did not match: $failed_tables"
fi
