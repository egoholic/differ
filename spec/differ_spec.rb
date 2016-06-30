require "spec_helper"

RSpec.describe Differ do
  let(:fpath1) { File.expand_path("../test_data/file1", __FILE__) }
  let(:fpath2) { File.expand_path("../test_data/file2", __FILE__) }

  describe "module" do
    subject { described_class }

    describe "#diff" do
      context "when good args" do
        context "when files are totally identical" do
          it "returns correct result" do
            expect(subject.diff fpath1, fpath1).to eq <<-OUTPUT
1   Some
2   Simple
3   Text
4   File
OUTPUT
          end
        end

        context "when files has some differences" do
          it "returns correct result" do
            expect(subject.diff fpath1, fpath2).to eq <<-OUTPUT
1 * Some|Another
2 - Simple
3   Text
4   File
5 + With
6 + Additional
7 + Lines
OUTPUT
          end
        end
      end

      xcontext "when bad args" do
        it "raises ArgumentError" do

        end
      end
    end
  end
end
