# frozen_string_literal: true

RSpec.describe PhNoToWord::Validator do
  it 'should raise RequiredArgumentMissingError if phone number empty' do
    err_msg = PhNoToWord::Constants::ERRORS[:missing_ph]
    expect { PhNoToWord.convert '' }.to raise_error(PhNoToWord::Error::RequiredArgumentMissingError, err_msg)
  end

  it 'should raise MalformattedArgumentError if phone number length is less than 10' do
    err_msg = PhNoToWord::Constants::ERRORS[:ph_length]
    expect { PhNoToWord.convert '228266868' }.to raise_error(PhNoToWord::Error::MalformattedArgumentError, err_msg)
    expect { PhNoToWord.convert '2' }.to raise_error(PhNoToWord::Error::MalformattedArgumentError, err_msg)
  end

  it 'should raise MalformattedArgumentError if phone number contains 0 or 1' do
    err_msg = PhNoToWord::Constants::ERRORS[:malformed_ph_no]
    expect { PhNoToWord.convert '2282668681' }.to raise_error(PhNoToWord::Error::MalformattedArgumentError, err_msg)
    expect { PhNoToWord.convert '2282068687' }.to raise_error(PhNoToWord::Error::MalformattedArgumentError, err_msg)
  end
end
