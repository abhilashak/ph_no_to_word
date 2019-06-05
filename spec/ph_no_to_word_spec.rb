# frozen_string_literal: true

RSpec.describe PhNoToWord do
  it 'has a version number' do
    expect(PhNoToWord::VERSION).not_to be nil
  end

  it `convert the given 10 digit phone number (2282668687) to words
      and return an array and expected result` do
    result = PhNoToWord.convert '2282668687'

    expect(result.is_a?(Array)).to be true
    expect(result).to include('act, amounts', 'catamounts', 'acta, oot, mus')
    expect(result.size).to eq(53)
  end

  it `convert the given 10 digit phone number (6686787825) to words
      and return an array and expected result` do
    result = PhNoToWord.convert '6686787825'

    expect(result.is_a?(Array)).to be true
    expect(result).to include('not, ort, suck', 'motortruck', 'motor, truck')
    expect(result.size).to eq(44)
  end

  it `convert the given 10 digit phone number (8325783555) to words
      and return an empty array` do
    result = PhNoToWord.convert '8325783555'

    expect(result).to be_empty
    expect(result.is_a?(Array)).to be true
  end

end
