require 'spec_helper'

describe FastTCPN::TCPN do
  describe "callback" do
    let :tcpn do
      m = FastTCPN::TCPN.new
      p1 = m.timed_place 'input'
      p2 = m.place 'output'
      t = m.transition 'send'
      t.input p1
      t.output p2 do |binding, clock|
        binding['input']
      end
      p1.add :data_package, 100
      m
    end

    describe "for transition" do
      shared_examples "calls callbacks" do
        it "is called when transition is fired" do
          count = 0
          tcpn.cb_for :transition, tag do |tag, event|
            expect(event.binding['input'].value).to eq :data_package
            expect(event.transition).to eq 'send'
            expect(event.clock).to eq 100
            count += 1
          end
          tcpn.sim
          expect(count).to eq expected_count
        end
      end
      describe "without tag" do
        let(:expected_count) { 2 }
        let(:tag) { }
        include_examples "calls callbacks"
      end

      describe "with :before tag" do
        let(:expected_count) { 1 }
        let(:tag) { :before }
        include_examples "calls callbacks"
      end

      describe "with :after tag" do
        let(:expected_count) { 1 }
        let(:tag) { :after }
        include_examples "calls callbacks"
      end

    end

    describe "for place" do
      it "is called when token is removed" do
        called = 0
        tcpn.cb_for :place, :remove do |tag, event|
          expect(tag).to eq :remove
          expect(event.place).to eq 'input'
          expect(event.clock).to eq 100
          expect(event.tokens.first.value).to eq :data_package
          called += 1
        end
        tcpn.sim
        expect(called).to eq 1
      end

      it "is called when token is added" do
        called = 0
        tcpn.cb_for :place, :add do |tag, event|
          expect(tag).to eq :add
          expect(event.place).to eq 'output'
          expect(event.clock).to eq nil # this place is not timed!
          called += 1
        end
        tcpn.sim
        expect(called).to eq 1
      end

      context "when token Array is added or removed" do
        let :tcpn do
          m = FastTCPN::TCPN.new
          p1 = m.timed_place 'input'
          p2 = m.place 'output'
          t = m.transition 'send'
          t.input p1
          t.output p2 do |binding, clock|
            binding['input']
          end
          t.sentry do |marking_for, clock, result|
            unless marking_for[p1.name].empty?
              tokens = marking_for[p1.name].to_a
              result << { p1.name => tokens }
            end
          end
          p1.add :data_package1, 100
          p1.add :data_package2, 100
          m
        end

        it "passes token array when it is added" do
          called = 0
          tcpn.cb_for :place, :add do |tag, event|
            expect(tag).to eq :add
            expect(event.place).to eq 'output'
            expect(event.tokens.map{ |t| t.value }).to match_array [ :data_package1, :data_package2 ]
            called += 1
          end
          tcpn.sim
          expect(called).to eq 1
        end
        it "passes token array when it is removed" do
          called = 0
          tcpn.cb_for :place, :remove do |tag, event|
            expect(tag).to eq :remove
            expect(event.place).to eq 'input'
            expect(event.clock).to eq 100
            expect(event.tokens.map{ |t| t.value }).to match_array [ :data_package1, :data_package2 ]
            called += 1
          end
          tcpn.sim
          expect(called).to eq 1
        end
      end
    end

    describe "for clock" do

      let :tcpn do
        m = FastTCPN::TCPN.new
        p1 = m.timed_place 'input'
        p2 = m.place 'output'
        t = m.transition 'send'
        t.input p1
        t.output p2 do |binding, clock|
          binding['input']
        end
        p1.add :data_package, 100
        m
      end

      it "is called before clock is changed" do
        called = 0
        tcpn.cb_for :clock, :before do |tag, event|
          expect(tag).to eq :before
          expect(event.clock).to eq(0) if called == 0
          called += 1
        end
        tcpn.sim
        expect(called).to be > 1
      end

      it "is called after clock is changed" do
        called = 0
        tcpn.cb_for :clock, :after do |tag, event|
          expect(tag).to eq :after
          expect(event.clock).to eq 100
          expect(event.previous_clock).to eq 0
          called += 1
        end
        tcpn.sim
        expect(called).to eq 1
      end
    end
  end
end
