USE kufflinks;

-- target + batch sizing
SET @target_total := 20000000;
SET @current      := (SELECT COUNT(*) FROM user_wallet_transaction);
SET @need         := GREATEST(0, @target_total - @current);
SET @batch        := LEAST(@need, 1000000);   -- bump up/down as needed

-- repeats per seed row (<= 1000 because our numbers table is 0..999)
SET @seed_count   := (SELECT COUNT(*) FROM seed_uwt);
SET @repeats      := CASE WHEN @seed_count=0 THEN 0 ELSE CEIL(@batch / @seed_count) END;
SET @repeats      := LEAST(@repeats, 1000);

-- fast session settings (OK if you're not replicating)
SET SESSION foreign_key_checks=0;
SET SESSION unique_checks=0;
SET SESSION sql_log_bin=0;

-- build + execute the INSERT (INSERT IGNORE skips any unique/FK collisions)
SET @sql := '
INSERT IGNORE INTO user_wallet_transaction (
  user_id,
  cash_type_metadata_id,
  cash_type_table_metadata_id,
  date_created,
  cash_transaction,
  cash_transaction_source_type,
  cash_transaction_id,
  cash_transaction_action,
  pool_investment_id,
  ready_to_payout,
  marked_for_payment,
  flag_is_reserved,
  flag_partial_payment,
  flag_is_transfer_out,
  flag_is_transfer_out_fees,
  campaign_id,
  updated_at,
  created_at,
  cash_type_id,
  transaction_type_id,
  action_id,
  action_type_id,
  tax_year_id
)
SELECT
  s.user_id,
  s.cash_type_metadata_id,
  s.cash_type_table_metadata_id,
  CASE WHEN s.date_created IS NULL
       THEN NOW() - INTERVAL (n.n % 365) DAY
       ELSE s.date_created + INTERVAL (n.n % 365) DAY
  END,
  COALESCE(ROUND(s.cash_transaction + (n.n % 100) * 0.01, 2),
           ROUND(RAND(n.n) * 1000, 2)),
  s.cash_transaction_source_type,

  -- Use a unique value so we don\'t get blocked by a unique index
  CONCAT(''SIM-'', COALESCE(s.cash_transaction_id, ''''), ''-'', n.n, ''-'', UUID()),
  -- If cash_transaction_id is NUMERIC instead, replace the line above with: UUID_SHORT() + n.n

  s.cash_transaction_action,
  s.pool_investment_id,
  IFNULL(s.ready_to_payout,            (n.n & 1)),
  IFNULL(s.marked_for_payment,         (n.n >> 1) & 1),
  IFNULL(s.flag_is_reserved,           (n.n >> 2) & 1),
  IFNULL(s.flag_partial_payment,       (n.n >> 3) & 1),
  IFNULL(s.flag_is_transfer_out,       (n.n >> 4) & 1),
  IFNULL(s.flag_is_transfer_out_fees,  (n.n >> 5) & 1),
  s.campaign_id,
  NOW(), NOW(),
  s.cash_type_id,
  s.transaction_type_id,
  s.action_id,
  s.action_type_id,
  s.tax_year_id
FROM seed_uwt s
JOIN _util_numbers_1000 n
  ON n.n < ?
LIMIT ?';

PREPARE ins FROM @sql;
START TRANSACTION;
EXECUTE ins USING @repeats, @batch;
COMMIT;
DEALLOCATE PREPARE ins;

SET SESSION foreign_key_checks=1;
SET SESSION unique_checks=1;
SET SESSION sql_log_bin=1;

SELECT @current AS current_rows, @need AS rows_needed, ROW_COUNT() AS rows_inserted,
       (SELECT COUNT(*) FROM user_wallet_transaction) AS total_after;
