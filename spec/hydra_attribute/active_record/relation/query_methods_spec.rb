require 'spec_helper'

__END__
describe HydraAttribute::ActiveRecord::Relation::QueryMethods do
  describe '#build_arel' do
    describe 'necessary columns for hydra attribute' do
      let(:id_column)           { Product.quoted_table_name + '.' + Product.quoted_primary_key }
      let(:hydra_set_id_column) { Product.quoted_table_name + '.' + Product.quoted_primary_key }

      it 'should add "id" and "hydra_set_id" columns to query if they are omitted' do
        arel = Product.select(:name).build_arel
        arel.to_sql.should match(id_column)
        arel.to_sql.should match(hydra_set_id_column)
      end

      it 'should not add "id" and "hydra_set_id" columns to default query' do
        arel = Product.scoped.build_arel
        arel.to_sql.should_not match(id_column)
        arel.to_sql.should_not match(hydra_set_id_column)
      end

      it 'should not add "id" and "hydra_set_id" columns to query which performs calculation' do
        scope = Product.select(:name)
        scope.hydra_attribute_performs_calculation = true

        arel = scope.build_arel
        arel.to_sql.should_not match(id_column)
        arel.to_sql.should_not match(hydra_set_id_column)
      end
    end
  end
end