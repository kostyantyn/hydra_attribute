require 'spec_helper'

describe HydraAttribute::ActiveRecord do
  describe '.has_many' do
    context 'dependent: :destroy' do
      before do
        Room.hydra_attributes.create(name: 'length', backend_type: 'integer')
        Room.hydra_attributes.create(name: 'width',  backend_type: 'integer')
      end

      context 'find' do
        let!(:flat)  { Flat.create! }
        let!(:room1) { Room.create!(flat_id: flat.id, square: 40, length: 5, width: 8) }
        let!(:room2) { Room.create!(flat_id: flat.id, square: 45, length: 5, width: 9) }

        it 'returns hydra associations with loaded hydra attributes' do
          rooms = flat.rooms
          expect(rooms).to match_array([room1, room2])

          attributes = [rooms[0].attributes.except('updated_at', 'created_at')]
          attributes << rooms[1].attributes.except('updated_at', 'created_at')
          expect(attributes).to match_array([
            room1.attributes.except('updated_at', 'created_at'),
            room2.attributes.except('updated_at', 'created_at')
          ])
        end

        it 'returns hydra associations filtered by hydra attribute' do
          rooms = flat.rooms.where(length: 5, width: 9)
          expect(rooms).to match_array([room2])
          expect(rooms.first.length).to eq(5)
          expect(rooms.first.width).to  eq(9)
          expect(rooms.first.square).to eq(45)
        end

        it 'returns hydra associations with filter by static attribute' do
          rooms = flat.rooms.where(square: 40)
          expect(rooms).to match_array([room1])
          expect(rooms.first.length).to eq(5)
          expect(rooms.first.width).to  eq(8)
          expect(rooms.first.square).to eq(40)
        end
      end

      context 'build' do
        let(:flat) { Flat.new }

        it 'returns new hydra association with hydra attributes' do
          room = flat.rooms.build(square: 20, length: 2, width: 10)
          expect(room.square).to eq(20)
          expect(room.length).to eq(2)
          expect(room.width).to  eq(10)
        end
      end

      context 'create' do
        let(:flat) { Flat.create! }

        it 'saves hydra associations with hydra attributes' do
          room = flat.rooms.create!(square: 20, length: 2, width: 10)
          expect(room.square).to eq(20)
          expect(room.length).to eq(2)
          expect(room.width).to  eq(10)
        end
      end

      context 'destroy' do
        let!(:flat)  { Flat.create! }
        let!(:room1) { Room.create!(flat_id: flat.id, square: 40, length: 5, width: 8) }
        let!(:room2) { Room.create!(flat_id: flat.id, square: 45, length: 5, width: 9) }

        it 'removes hydra associations and theirs hydra values' do
          flat.destroy
          expect(Room.count).to be(0)

          query = HydraAttribute::HydraValue.arel_tables[Room.table_name]['integer'].project(Arel.star.count)
          count = ActiveRecord::Base.connection.select_value(query).to_i
          expect(count).to be(0)
        end
      end
    end
  end

  describe '.belongs_to' do
    before do
      Flat.hydra_attributes.create(name: 'floor', backend_type: 'integer')
    end

    context 'find' do
      let!(:flat) { Flat.create!(number: 100, floor: 5) }
      let!(:room) { Room.create!(flat_id: flat.id) }

      it 'returns hydra association' do
        expect(room.flat).to eq(flat)
        expect(room.flat.number).to be(100)
        expect(room.flat.floor).to  be(5)
      end
    end

    context 'build' do
      let(:room) { Room.new }

      it 'returns hydra association' do
        flat = room.build_flat(number: 100, floor: 3)
        expect(flat.number).to be(100)
        expect(flat.floor).to  be(3)
      end
    end

    context 'create' do
      let(:room) { Room.create! }

      it 'returns hydra association' do
        flat = room.create_flat!(number: 100, floor: 3)
        expect(flat.number).to be(100)
        expect(flat.floor).to  be(3)
      end
    end
  end

  describe '.inspect' do
    before do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code',  backend_type: 'string', white_list: true)
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'decimal', white_list: true)
    end

    it 'should include hydra attributes in inspection string too' do
      Product.inspect.should == 'Product(id: integer, hydra_set_id: integer, name: string, created_at: datetime, updated_at: datetime, code: string, price: decimal)'
    end
  end

  describe '.new' do
    let!(:attr1) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code',    backend_type: 'string',   default_value: nil, white_list: true) }
    let!(:attr2) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'info',    backend_type: 'string',   default_value: '', white_list: true) }
    let!(:attr3) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'total',   backend_type: 'integer',  default_value: 0, white_list: true) }
    let!(:attr4) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price',   backend_type: 'float',    default_value: 0, white_list: true) }
    let!(:attr5) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'active',  backend_type: 'boolean',  default_value: 0, white_list: true) }
    let!(:attr6) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'started', backend_type: 'datetime', default_value: '2013-01-01', white_list: true) }

    let(:product) { Product.new(attributes) }

    describe 'without any attributes' do
      let(:attributes) { {} }

      it 'should return default values' do
        product.code.should be_nil
        product.info.should == ''
        product.total.should be(0)
        product.price.should == 0.0
        product.active.should be_false
        product.started.should == Time.utc('2013-01-01')
      end
    end

    describe 'with "code", "info" and "price" attributes' do
      let(:attributes) { {code: 'a', info: nil, price: nil} }

      it 'should save these attributes into database' do
        product.code.should == 'a'
        product.info.should be_nil
        product.total.should be(0)
        product.price.should == nil
        product.active.should be_false
        product.started.should == Time.utc('2013-01-01')
      end
    end

    describe 'with all attributes' do
      let(:attributes) { {code: 'a', info: 'b', total: 3, price: 4.3, active: true, started: Time.utc('2013-02-03')} }

      it 'should save all these attributes into database' do
        product.code.should == 'a'
        product.info.should == 'b'
        product.total.should == 3
        product.price.should == 4.3
        product.active.should be_true
        product.started.should == Time.utc('2013-02-03')
      end
    end

    describe 'with all attributes and hydra_set_id' do
      let(:hydra_set_id) { HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default').id }
      let(:attributes)   { {code: 'a', info: 'b', total: 3, price: 4.3, active: true, started: Time.utc('2013-02-03'), hydra_set_id: hydra_set_id} }

      before do
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: attr1.id)
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: attr3.id)
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: attr5.id)
      end

      it 'should save only attributes from this hydra set' do
        product.code.should == 'a'
        lambda { product.info }.should raise_error HydraAttribute::HydraSet::MissingAttributeInHydraSetError, "Attribute ID #{attr2.id} is missed in Set ID #{hydra_set_id}"
        product.total.should == 3
        lambda { product.price }.should raise_error HydraAttribute::HydraSet::MissingAttributeInHydraSetError, "Attribute ID #{attr4.id} is missed in Set ID #{hydra_set_id}"
        product.active.should be_true
        lambda { product.started }.should raise_error HydraAttribute::HydraSet::MissingAttributeInHydraSetError, "Attribute ID #{attr6.id} is missed in Set ID #{hydra_set_id}"
      end

      it 'should not raise an error when missing attribute in set was passed' do
        lambda do
          Product.new(
            :hydra_set_id => hydra_set_id,
            attr1.name    => 1,
            attr2.name    => 2,
            attr3.name    => 3,
            attr4.name    => 4,
            attr5.name    => 5,
            attr6.name    => 5)
        end.should_not raise_error
      end
    end
  end

  describe '.create' do
    let!(:attr1) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code',    backend_type: 'string',   default_value: nil, white_list: true) }
    let!(:attr2) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'info',    backend_type: 'string',   default_value: '', white_list: true) }
    let!(:attr3) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'total',   backend_type: 'integer',  default_value: 0, white_list: true) }
    let!(:attr4) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price',   backend_type: 'float',    default_value: 0, white_list: true) }
    let!(:attr5) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'active',  backend_type: 'boolean',  default_value: 0, white_list: true) }
    let!(:attr6) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'started', backend_type: 'datetime', default_value: '2013-01-01', white_list: true) }

    let(:product) { Product.find(Product.create(attributes).id) }

    describe 'without any attributes' do
      let(:attributes) { {} }

      it 'should have default values' do
        product.code.should be_nil
        product.info.should == ''
        product.total.should be(0)
        product.price.should == 0.0
        product.active.should be_false
        product.started.should == Time.utc('2013-01-01')
      end
    end

    describe 'with "code", "info" and "price" attributes' do
      let(:attributes) { {code: 'a', info: nil, price: nil} }

      it 'should save these attributes into database' do
        product.code.should == 'a'
        product.info.should be_nil
        product.total.should be(0)
        product.price.should == nil
        product.active.should be_false
        product.started.should == Time.utc('2013-01-01')
      end
    end

    describe 'with all attributes' do
      let(:attributes) { {code: 'a', info: 'b', total: 3, price: 4.3, active: true, started: Time.utc('2013-02-03')} }

      it 'should save all these attributes into database' do
        product.code.should == 'a'
        product.info.should == 'b'
        product.total.should == 3
        product.price.should == 4.3
        product.active.should be_true
        product.started.should == Time.utc('2013-02-03')
      end
    end

    describe 'with all attributes and hydra_set_id' do
      let(:hydra_set_id) { HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default').id }
      let(:attributes)   { {code: 'a', info: 'b', total: 3, price: 4.3, active: true, started: Time.utc('2013-02-03'), hydra_set_id: hydra_set_id} }

      before do
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: attr1.id)
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: attr3.id)
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: hydra_set_id, hydra_attribute_id: attr5.id)
      end

      let(:value) { ->(entity, attr) { ActiveRecord::Base.connection.select_value("SELECT value FROM hydra_#{attr.backend_type}_#{entity.class.table_name} WHERE entity_id = #{entity.id} AND hydra_attribute_id = #{attr.id}") } }

      it 'should save only attributes from this hydra set' do
        value.(product, attr1).should == 'a'
        value.(product, attr2).should be_nil
        value.(product, attr3).to_i.should == 3
        value.(product, attr4).should be_nil
        ActiveRecord::ConnectionAdapters::Column::TRUE_VALUES.should include(value.(product, attr5))
        value.(product, attr6).should be_nil
      end
    end
  end

  describe '.find' do
    before do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string', white_list: true)
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'integer', white_list: true)
    end

    it 'should have hydra attributes' do
      product = Product.create(name: 'one', title: 'wow', code: 42)
      product = Product.find(product.id)
      product.name.should  == 'one'
      product.title.should == 'wow'
      product.code.should  == 42
    end
  end

  describe '.count' do
    before do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string', white_list: true)
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'integer', white_list: true)
      Product.create(name: 'one', title: 'abc', code: 42)
      Product.create(name: 'two', title: 'qwe', code: 52)
    end

    it 'should correct count the number of records' do
      Product.count.should be(2)
    end
  end

  describe '.group' do
    before do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'integer', white_list: true)
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string', white_list: true)
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'total', backend_type: 'integer', white_list: true)

      Product.create(name: 'a', code: 1, title: 'q', total: 5)
      Product.create(name: 'b', code: 2, title: 'w', total: 5)
      Product.create(name: 'b', code: 3, title: 'w')
      Product.create(name: 'c', code: 4, title: 'e')
    end

    describe 'without where condition' do
      it 'should be able to group by hydra and by static attributes' do
        Product.group(:name).count.stringify_keys.should  == {'a'=>1, 'b'=>2, 'c'=>1}
        Product.group(:code).count.stringify_keys.should  == {'1'=>1, '2'=>1, '3'=>1, '4'=>1}
        Product.group(:total).count.stringify_keys.should == {'5'=>2, ''=>2}
        Product.group(:name, :title).count.should         == {%w[a q]=>1, %w[b w]=>2, %w[c e]=>1}
      end
    end

    describe 'with where condition' do
      it 'should be able to group by hydra and by static attributes' do
        Product.where(title: 'w').group(:name).count.stringify_keys.should  == {'b'=>2}
        Product.where(title: 'w').group(:code).count.stringify_keys.should  == {'2'=>1, '3'=>1}
        Product.where(title: 'w').group(:total).count.stringify_keys.should == {'5'=>1, ''=>1}
        Product.where(total: nil).group(:name, :title).count.should         == {%w[b w]=>1, %w[c e]=>1}
      end
    end
  end

  describe '.order' do
    before do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'state', backend_type: 'integer', white_list: true)
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string', white_list: true)

      Product.create(name: 'a', state: 3, title: 'c')
      Product.create(name: 'b', state: 2, title: 'b')
      Product.create(name: 'c', state: 1, title: 'b')
    end

    it 'should order by one field' do
      Product.order(:name).map(&:name).should == %w[a b c]
      Product.order(:state).map(&:name).should == %w[c b a]
    end

    it 'should order by two fields' do
      Product.order(:title, :state).map(&:name).should == %w[c b a]
      Product.order(:title, :name).map(&:name).should == %w[b c a]
    end

    it 'should order by field with with filter' do
      Product.where(name: %w[a b]).order(:title).map(&:name).should == %w[b a]
      Product.where(title: 'b').order(:state).map(&:name).should == %w[c b]
    end
  end

  describe '.reverse_order' do
    before do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'state', backend_type: 'integer', white_list: true)
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string', white_list: true)

      Product.create(name: 'a', state: 3, title: 'c')
      Product.create(name: 'b', state: 2, title: 'b')
      Product.create(name: 'c', state: 1, title: 'b')
    end

    it 'should order by one field and reorder list' do
      Product.order(:name).reverse_order.map(&:name).should == %w[c b a]
      Product.order(:state).reverse_order.map(&:name).should == %w[a b c]
    end

    it 'should order by two fields and reorder list' do
      Product.order(:title, :state).reverse_order.map(&:name).should == %w[a b c]
      Product.order(:title, :name).reverse_order.map(&:name).should == %w[a c b]
    end

    it 'should order by field with with filter and reorder list' do
      Product.where(name: %w[a b]).order(:title).reverse_order.map(&:name).should == %w[a b]
      Product.where(title: 'b').order(:state).reverse_order.map(&:name).should == %w[b c]
    end
  end

  describe '.reorder' do
    before do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'state', backend_type: 'integer', white_list: true)
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string', white_list: true)

      Product.create(name: 'a', state: 3, title: 'c')
      Product.create(name: 'b', state: 2, title: 'b')
      Product.create(name: 'c', state: 1, title: 'b')
    end

    it 'should order by one field' do
      Product.order(:name).reorder(:state).map(&:name).should == %w[c b a]
      Product.order(:state).reorder(:name).map(&:name).should == %w[a b c]
    end

    it 'should order by two fields' do
      Product.order(:title, :state).reorder(:title, :name).map(&:name).should == %w[b c a]
      Product.order(:title, :name).reorder(:title, :state).map(&:name).should == %w[c b a]
    end

    it 'should order by field with with filter' do
      Product.where(name: %w[b c]).order(:title).reorder(:state).map(&:name).should == %w[c b]
      Product.where(title: %w[b c]).order(:name).reorder(:state).map(&:name).should == %w[c b a]
    end
  end

  describe '.where' do
    let!(:attr1) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'info',    backend_type: 'string',   white_list: true)   }
    let!(:attr2) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'total',   backend_type: 'integer',  white_list: true)  }
    let!(:attr3) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price',   backend_type: 'float',    white_list: true)    }
    let!(:attr4) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'active',  backend_type: 'boolean',  white_list: true)  }
    let!(:attr5) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'started', backend_type: 'datetime', white_list: true) }

    describe 'without attribute sets' do
      before do
        Product.create(name: 'a', info: 'a', total: 2,   price: 3.5, active: true,  started: '2013-01-01')
        Product.create(name: 'b', info: 'a', total: 3,   price: nil, active: false, started: '2013-01-02')
        Product.create(name: 'c' ,info: 'b', total: nil, price: nil, active: nil,   started: '2013-01-01')
        Product.create(name: 'd', info: nil, total: 3,   price: 3.5, active: true,  started: nil)
      end

      it 'should filter by one attribute' do
        Product.where(info: 'a').map(&:name).should =~ %w[a b]
        Product.where(info: nil).map(&:name).should =~ %w[d]
        Product.where(total: 3).map(&:name).should =~ %w[b d]
        Product.where(total: nil).map(&:name).should =~ %w[c]
        Product.where(price: 3.5).map(&:name).should =~ %w[a d]
        Product.where(price: nil).map(&:name).should =~ %w[b c]
        Product.where(active: true).map(&:name).should =~ %w[a d]
        Product.where(active: false).map(&:name).should =~ %w[b]
        Product.where(active: nil).map(&:name).should =~ %w[c]
        Product.where(started: Time.utc('2013-01-01')).map(&:name).should =~ %w[a c]
        Product.where(started: nil).map(&:name).should =~ %w[d]
      end

      it 'should filter by several attributes' do
        Product.where(info: %w[a b], name: %w[b c]).map(&:name).should =~ %w[b c]
        Product.where(info: %w[a b], price: nil).map(&:name).should =~ %w[b c]
        Product.where(active: nil, started: Time.utc('2013-01-01')).map(&:name).should =~ %w[c]
        Product.where(price: 3.5,  started: nil).map(&:name).should =~ %w[d]
        Product.where(total: 3,  active: true).map(&:name).should =~ %w[d]
      end
    end

    describe 'with attribute sets' do
      before do
        set1 = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default')
        set2 = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'second')
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: set1.id, hydra_attribute_id: attr1.id)
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: set2.id, hydra_attribute_id: attr2.id)
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: set1.id, hydra_attribute_id: attr3.id)
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: set2.id, hydra_attribute_id: attr4.id)
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: set1.id, hydra_attribute_id: attr5.id)

        p1 = Product.create(name: 'a', info: 'a', total: 2,   price: 3.5, active: true,  started: '2013-01-01')
        p2 = Product.create(name: 'b', info: 'a', total: 3,   price: nil, active: false, started: '2013-01-02')
        p3 = Product.create(name: 'c' ,info: 'b', total: nil, price: nil, active: nil,   started: '2013-01-01')
        p4 = Product.create(name: 'd', info: nil, total: 3,   price: 3.5, active: true,  started: nil)
        p5 = Product.create(name: 'e', info: 'c', total: 7,   price: 4.2, active: false, started: '2013-01-03')
        p6 = Product.create(name: 'f', info: 'c', total: 5,   price: 4.2, active: false, started: '2013-01-03')
        p7 = Product.create(name: 'g', info: nil, total: 7,   price: 5.5, active: nil,   started: nil)
        p1.hydra_set_id = nil
        p2.hydra_set_id = set1.id
        p3.hydra_set_id = set2.id
        p4.hydra_set_id = set2.id
        p5.hydra_set_id = set1.id
        p6.hydra_set_id = set1.id
        p7.hydra_set_id = nil
        [p1, p2, p3, p4, p5, p6, p7].each(&:save)
      end

      it 'should filter by one attribute' do
        Product.where(info: 'a').map(&:name).should =~ %w[a b]
        Product.where(info: nil).map(&:name).should =~ %w[g]
        Product.where(total: 3).map(&:name).should =~ %w[d]
        Product.where(total: nil).map(&:name).should =~ %w[c]
        Product.where(price: 3.5).map(&:name).should =~ %w[a]
        Product.where(price: nil).map(&:name).should =~ %w[b]
        Product.where(active: true).map(&:name).should =~ %w[a d]
        Product.where(active: false).map(&:name).should == []
        Product.where(active: nil).map(&:name).should =~ %w[c g]
        Product.where(started: Time.utc('2013-01-01')).map(&:name).should =~ %w[a]
        Product.where(started: nil).map(&:name).should =~ %w[g]
      end

      it 'should filter by several attributes' do
        Product.where(info: ['a', 'b', 'c', nil], name: %w[a b c d e f g]).map(&:name).should =~ %w[a b e f g]
        Product.where(info: %w[a b], price: nil).map(&:name).should =~ %w[b]
        Product.where(active: nil, started: Time.utc('2013-01-01')).map(&:name).should == []
        Product.where(price: 3.5,  started: Time.utc('2013-01-01')).map(&:name).should =~ %w[a]
        Product.where(total: [3, 5, 7],  active: [true, false]).map(&:name).should =~ %w[d]
      end
    end
  end

  describe '.select' do
    let!(:attr1) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code',     backend_type: 'string',  white_list: true) }
    let!(:attr2) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'quantity', backend_type: 'integer', white_list: true) }
    let!(:attr3) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title',    backend_type: 'string',  white_list: true) }
    let!(:attr4) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'active',   backend_type: 'boolean', white_list: true) }
    let!(:set1)  { HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default') }
    let!(:set2)  { HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'second') }

    before do
      HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: attr1.id, hydra_set_id: set1.id)
      HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: attr2.id, hydra_set_id: set2.id)
      HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: attr3.id, hydra_set_id: set1.id)
      HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: attr4.id, hydra_set_id: set2.id)

      Product.create(name: 'name1', code: 'code1', quantity: 1, title: 'title1', active: true,  hydra_set_id: nil)
      Product.create(name: 'name2', code: 'code2', quantity: 2, title: 'title2', active: false, hydra_set_id: set1.id)
      Product.create(name: 'name3', code: 'code3', quantity: 3, title: 'title3', active: true,  hydra_set_id: set2.id)
      Product.create(name: 'name4', code: 'code4', quantity: 4, title: 'title4', active: false, hydra_set_id: set1.id)
    end

    it 'should select only specific attributes and return models which have all these attributes in the attribute set' do
      relation = Product.select([:name, :code])

      relation.map(&:name).should =~ %w[name1 name2 name4]
      relation.map(&:code).should =~ %w[code1 code2 code4]

      entity_without_set, entity_with_set = relation.partition { |entity| entity.hydra_set_id.nil? }
      entity_without_set.should have(1).item
      entity_with_set.should have(2).items

      lambda { entity_without_set.map(&:quantity) }.should raise_error(HydraAttribute::HydraEntityAttributeAssociation::AttributeWasNotSelectedError, "Attribute ID #{attr2.id} was not selected from DB")
      lambda { entity_without_set.map(&:title) }.should    raise_error(HydraAttribute::HydraEntityAttributeAssociation::AttributeWasNotSelectedError, "Attribute ID #{attr3.id} was not selected from DB")
      lambda { entity_without_set.map(&:active) }.should   raise_error(HydraAttribute::HydraEntityAttributeAssociation::AttributeWasNotSelectedError, "Attribute ID #{attr4.id} was not selected from DB")

      entity_with_set.each do |entity|
        lambda { entity.quantity }.should raise_error(HydraAttribute::HydraSet::MissingAttributeInHydraSetError, "Attribute ID #{attr2.id} is missed in Set ID #{set1.id}")
        lambda { entity.title }.should    raise_error(HydraAttribute::HydraEntityAttributeAssociation::AttributeWasNotSelectedError, "Attribute ID #{attr3.id} was not selected from DB")
        lambda { entity.active }.should   raise_error(HydraAttribute::HydraSet::MissingAttributeInHydraSetError, "Attribute ID #{attr4.id} is missed in Set ID #{set1.id}")
      end

      relation = Product.select([:name, :quantity])
      relation.map(&:name).should     =~ %w[name1 name3]
      relation.map(&:quantity).should =~ [1, 3]

      entity_without_set, entity_with_set = relation.partition { |entity| entity.hydra_set_id.nil? }
      entity_without_set.should have(1).item
      entity_with_set.should have(1).item

      lambda { entity_without_set.map(&:code) }.should   raise_error(HydraAttribute::HydraEntityAttributeAssociation::AttributeWasNotSelectedError, "Attribute ID #{attr1.id} was not selected from DB")
      lambda { entity_without_set.map(&:title) }.should  raise_error(HydraAttribute::HydraEntityAttributeAssociation::AttributeWasNotSelectedError, "Attribute ID #{attr3.id} was not selected from DB")
      lambda { entity_without_set.map(&:active) }.should raise_error(HydraAttribute::HydraEntityAttributeAssociation::AttributeWasNotSelectedError, "Attribute ID #{attr4.id} was not selected from DB")

      lambda { entity_with_set.map(&:code) }.should   raise_error(HydraAttribute::HydraSet::MissingAttributeInHydraSetError, "Attribute ID #{attr1.id} is missed in Set ID #{set2.id}")
      lambda { entity_with_set.map(&:title) }.should  raise_error(HydraAttribute::HydraSet::MissingAttributeInHydraSetError, "Attribute ID #{attr3.id} is missed in Set ID #{set2.id}")
      lambda { entity_with_set.map(&:active) }.should raise_error(HydraAttribute::HydraEntityAttributeAssociation::AttributeWasNotSelectedError, "Attribute ID #{attr4.id} was not selected from DB")
    end

    it 'should be able to apply filter condition' do
      relation = Product.select([:name, :code]).where(code: %w[code2 code3 code4])
      relation.map(&:name).should =~ %w[name2 name4]
      relation.map(&:code).should =~ %w[code2 code4]
    end

    it 'select attributes which were created after entities and their values should be always nil' do
      attr = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'color', backend_type: 'string', default_value: 'red')
      HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: attr.id, hydra_set_id: set1.id)

      relation = Product.select([:name, :color])
      relation.map(&:name).should  =~ %w[name1 name2 name4]
      relation.map(&:color).should == [nil, nil, nil]
    end
  end

  describe '#save' do
    let!(:attr_id) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'string', default_value: 'abc').id.to_i }

    describe 'new model' do
      let(:product) { Product.new }

      it 'should save with default attribute values' do
        product.save
        value = ::ActiveRecord::Base.connection.select_value("SELECT value FROM hydra_string_products WHERE entity_id = #{product.id} AND hydra_attribute_id = #{attr_id}")
        value.should == 'abc'
      end

      it 'should save changed attribute value' do
        product.code = 'qwe'
        product.save
        value = ::ActiveRecord::Base.connection.select_value("SELECT value FROM hydra_string_products WHERE entity_id = #{product.id} AND hydra_attribute_id = #{attr_id}")
        value.should == 'qwe'
      end

      it 'should save only attributes which are belong to hydra set' do
        attr_id2 = HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'color', backend_type: 'string', white_list: true).id
        set_id   = HydraAttribute::HydraSet.create(entity_type: 'Product', name: 'default').id
        HydraAttribute::HydraAttributeSet.create(hydra_set_id: set_id, hydra_attribute_id: attr_id2)

        product.code  = 'qwerty'
        product.color = 'green'
        product.hydra_set_id = set_id
        product.save

        attr1 = ::ActiveRecord::Base.connection.select_value("SELECT value FROM hydra_string_products WHERE entity_id = #{product.id} AND hydra_attribute_id = #{attr_id}")
        attr1.should be_nil

        attr2 = ::ActiveRecord::Base.connection.select_value("SELECT value FROM hydra_string_products WHERE entity_id = #{product.id} AND hydra_attribute_id = #{attr_id2}")
        attr2.should == 'green'
      end
    end

    describe 'persisted model' do
      let(:product) { Product.create }

      it 'should not touch entity if hydra attributes were not changed' do
        updated_at = product.updated_at
        product.save
        product.updated_at.should == updated_at
      end

      it 'should touch entity if hydra attributes were changed' do
        updated_at = product.updated_at
        product.code = 'qwe'
        product.save
        product.updated_at.should > updated_at
      end
    end
  end

  describe '#destroy' do
    let!(:attr1) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'title', backend_type: 'string', white_list: true) }
    let!(:attr2) { HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code', backend_type: 'integer', white_list: true) }

    let(:find_query) { ->(entity_id, attr) { "SELECT value FROM hydra_#{attr.backend_type}_products WHERE entity_id = #{entity_id} AND hydra_attribute_id = #{attr.id}" } }
    let(:find_value) { ->(entity_id, attr) { ::ActiveRecord::Base.connection.select_value(find_query.(entity_id, attr)) } }

    it 'should destroy all saved attributes for current entity' do
      product1 = Product.create(title: 'abc', code: 42)
      product2 = Product.create(title: 'qwe', code: 55)

      find_value.(product1.id, attr1).should      == 'abc'
      find_value.(product1.id, attr2).to_i.should == 42
      find_value.(product2.id, attr1).should      == 'qwe'
      find_value.(product2.id, attr2).to_i.should == 55
      product1.destroy
      find_value.(product1.id, attr1).should be_nil
      find_value.(product1.id, attr2).should be_nil
      find_value.(product2.id, attr1).should      == 'qwe'
      find_value.(product2.id, attr2).to_i.should == 55
    end
  end

  describe '#attributes' do
    it 'should return entity attributes with its hydra attributes' do
      product = Product.new
      product.attributes.should == {'id'=>nil, 'hydra_set_id'=>nil, 'name'=>nil, 'created_at'=>nil, 'updated_at'=>nil}

      a1 = Product.hydra_attributes.create(name: 'total', backend_type: 'decimal', default_value: 5)
      a2 = Product.hydra_attributes.create(name: 'title', backend_type: 'string',  default_value: 'one')

      product = Product.new
      product.attributes.should == {'id'=>nil, 'hydra_set_id'=>nil, 'name'=>nil, 'created_at'=>nil, 'updated_at'=>nil, 'total'=>5, 'title'=>'one'}

      set = Product.hydra_sets.create(name: 'default')
      HydraAttribute::HydraAttributeSet.create(hydra_attribute_id: a1.id, hydra_set_id: set.id)

      product.hydra_set_id = set.id
      product.attributes.should == {'id'=>nil, 'hydra_set_id'=>set.id, 'name'=>nil, 'created_at'=>nil, 'updated_at'=>nil, 'total'=>5}
    end
  end

  describe '#inspect' do
    before do
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'code',  backend_type: 'string', default_value: 'one')
      HydraAttribute::HydraAttribute.create(entity_type: 'Product', name: 'price', backend_type: 'float',  default_value: 5)
    end

    let(:product) { Product.new }

    it 'should include hydra attributes in inspection string too' do
      product.inspect.should == '#<Product id: nil, hydra_set_id: nil, name: nil, created_at: nil, updated_at: nil, code: "one", price: 5.0>'
    end
  end
end
