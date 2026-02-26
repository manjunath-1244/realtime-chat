class BackfillPublishedAtForExistingMessages < ActiveRecord::Migration[7.1]
  def up
    execute <<~SQL.squish
      UPDATE messages
      SET published_at = COALESCE(created_at, NOW())
      WHERE published_at IS NULL
        AND scheduled_for IS NULL
        AND deleted_at IS NULL
    SQL
  end

  def down
    # no-op: keep published markers once backfilled
  end
end
