# frozen_string_literal: true

class RemoveWantedCanteens < ActiveRecord::Migration[6.1]
  def up
    change_column_default :canteens, :state, "new"

    # Migrate all wanted canteens that have a source to the new "new" state.
    # This state indicates a canteen that has no data yet because it has just
    # been created or un-archived.
    #
    # After that, remove all still wanted canteens. They are part of the
    # deprecated wishlist feature.
    execute <<~SQL.squish
      UPDATE canteens SET state = 'new' WHERE state = 'wanted' AND id IN (SELECT canteen_id FROM sources);
      DELETE FROM canteens WHERE state = 'wanted';
    SQL
  end
end
