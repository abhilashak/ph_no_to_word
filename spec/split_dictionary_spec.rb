# frozen_string_literal: true

RSpec.describe PhNoToWord::SplitDictionary do
  it 'should split the provided dictionary file' do
    expect { PhNoToWord::SplitDictionary.split_files('fake/path/test.txt') }.to raise_error(PhNoToWord::Error::FileNotExists)
  end
end
