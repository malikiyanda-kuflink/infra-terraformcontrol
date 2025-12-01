import csv
import sys
import pymysql
import psycopg2
from pymysql import err as pymysql_err
from psycopg2 import OperationalError as PsycopgOperationalError

# --- CONFIG: UPDATE THESE FOR TEST ---
RDS_CONFIG = {
    "host": "kuff-test-mysql.brickfin.co.uk",
    "port": 3306,
    "user": "kuflink_db_admin",
    "password": "kmWcYrqSJF3*vh^bcT%BexrgraG6bH6B",  # <-- put test password back here
    "db": "kufflinks",
}

REDSHIFT_CONFIG = {
    "host": "kuff-test-redshift.brickfin.co.uk",
    "port": 5439,
    "user": "admin",
    "password": "fJd4VU2iD2ZUGpLBXPbGUn82x",  # <-- put test password back here
    "db": "analytics",
    "schema": "kufflinks",
}

# Only do COUNT(*) on these "important" tables (case-insensitive)
FOCUS_TABLES = [
    "user",
    "user_wallet",
    "user_wallet_transaction",
    "deal_investment",
    "pool_investment",
    "loan",
]

FULL_CSV = "dms_validation_kufflinks_test_full.csv"
SUMMARY_CSV = "dms_validation_kufflinks_test_summary.csv"
# --------------------------------------


def get_rds_conn():
    try:
        return pymysql.connect(**RDS_CONFIG)
    except pymysql_err.OperationalError as e:
        print(
            f"[ERROR] Failed to connect to RDS MySQL at {RDS_CONFIG['host']}:{RDS_CONFIG['port']} "
            f"as {RDS_CONFIG['user']}"
        )
        print("        MySQL error:", e)
        print("        Hint: Check username/password, and that this host/IP is allowed in MySQL and SGs.")
        sys.exit(1)


def get_redshift_conn():
    try:
        return psycopg2.connect(
            host=REDSHIFT_CONFIG["host"],
            port=REDSHIFT_CONFIG["port"],
            user=REDSHIFT_CONFIG["user"],
            password=REDSHIFT_CONFIG["password"],
            dbname=REDSHIFT_CONFIG["db"],
        )
    except PsycopgOperationalError as e:
        print(
            f"[ERROR] Failed to connect to Redshift at {REDSHIFT_CONFIG['host']}:{REDSHIFT_CONFIG['port']} "
            f"as {REDSHIFT_CONFIG['user']}"
        )
        print("        Redshift error:", e)
        print("        Hint: Check username/password, SGs, and that your client can reach this endpoint.")
        sys.exit(1)


def get_rds_tables():
    conn = get_rds_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = %s
                """,
                (RDS_CONFIG["db"],),
            )
            return {row[0] for row in cur.fetchall()}
    finally:
        conn.close()


def get_redshift_tables():
    conn = get_redshift_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT table_name
                FROM information_schema.tables
                WHERE table_schema = %s
                """,
                (REDSHIFT_CONFIG["schema"],),
            )
            return {row[0] for row in cur.fetchall()}
    finally:
        conn.close()


def get_rds_count(table):
    conn = get_rds_conn()
    try:
        with conn.cursor() as cur:
            # backticks for reserved names like `user`
            cur.execute(f"SELECT COUNT(*) FROM `{table}`")
            return cur.fetchone()[0]
    finally:
        conn.close()


def get_redshift_count(table):
    conn = get_redshift_conn()
    try:
        with conn.cursor() as cur:
            cur.execute(f'SET search_path TO "{REDSHIFT_CONFIG["schema"]}"')
            # quote reserved name "user" in Redshift
            if table.lower() == "user":
                cur.execute('SELECT COUNT(*) FROM "user"')
            else:
                cur.execute(f"SELECT COUNT(*) FROM {table}")
            return cur.fetchone()[0]
    finally:
        conn.close()


def main():
    print("[INFO] Fetching table lists from RDS and Redshift...")
    rds_tables = get_rds_tables()
    rs_tables = get_redshift_tables()

    # normalise to lowercase for matching
    rds_lower = {t.lower(): t for t in rds_tables}
    rs_lower = {t.lower(): t for t in rs_tables}

    focus_lower = {t.lower() for t in FOCUS_TABLES}
    all_keys = sorted(set(rds_lower.keys()) | set(rs_lower.keys()))

    rows = []

    print("[INFO] Comparing tables and calculating counts for focus tables...")
    for key in all_keys:
        rds_name = rds_lower.get(key)
        rs_name = rs_lower.get(key)
        in_rds = 1 if rds_name else 0
        in_rs = 1 if rs_name else 0

        rds_count = rs_count = None
        diff = ""
        status = ""

        # Only do COUNT(*) when table exists on both sides AND in focus list
        is_in_focus = key in focus_lower

        if in_rds and in_rs and (not focus_lower or is_in_focus):
            try:
                rds_count = get_rds_count(rds_name)
                rs_count = get_redshift_count(rs_name)
                diff_val = (rds_count or 0) - (rs_count or 0)
                diff = diff_val

                if diff_val == 0:
                    status = "OK"
                else:
                    status = f"Count mismatch ({diff_val})"
            except Exception as e:
                status = f"Error during count: {e}"
        else:
            if in_rds and not in_rs:
                status = "Missing in Redshift"
            elif in_rs and not in_rds:
                status = "Redshift-only (likely ETL/dbt)"
            else:
                status = "Not in focus list"

        rows.append(
            [
                REDSHIFT_CONFIG["schema"],
                rds_name or "",
                rs_name or "",
                in_rds,
                in_rs,
                rds_count if rds_count is not None else "",
                rs_count if rs_count is not None else "",
                diff,
                status,
            ]
        )

    # Write full CSV (everything)
    print(f"[INFO] Writing full CSV: {FULL_CSV}")
    with open(FULL_CSV, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(
            [
                "schema",
                "table_name_rds",
                "table_name_redshift",
                "in_rds",
                "in_redshift",
                "rds_count",
                "rs_count",
                "count_diff",
                "status",
            ]
        )
        writer.writerows(rows)

    # Write summary CSV (only interesting rows)
    print(f"[INFO] Writing summary CSV: {SUMMARY_CSV}")
    with open(SUMMARY_CSV, "w", newline="") as f:
        writer = csv.writer(f)
        writer.writerow(
            [
                "schema",
                "table_name_rds",
                "table_name_redshift",
                "in_rds",
                "in_redshift",
                "rds_count",
                "rs_count",
                "count_diff",
                "status",
            ]
        )

        for r in rows:
            schema, rds_name, rs_name, in_rds, in_rs, rds_count, rs_count, diff, status = r

            has_name = bool(rds_name or rs_name)
            is_focus = has_name and (
                (rds_name and rds_name.lower() in focus_lower)
                or (rs_name and rs_name.lower() in focus_lower)
            )

            if (
                status.startswith("Missing in Redshift")
                or status.startswith("Redshift-only")
                or status.startswith("Count mismatch")
                or (is_focus and status == "OK")
            ):
                writer.writerow(r)

    print(f"[INFO] Done. Wrote {FULL_CSV} and {SUMMARY_CSV}")


if __name__ == "__main__":
    main()
