require 'csv'
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def legislators_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def save_thank_you_letters(id, form_letter)
  Dir.mkdir('output') unless Dir.exists?('output')
  filename = "output/thanks_#{id}.html"
  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

def is_digit?(character)
  character =~ /[[:digit:]]/
end

def remove_non_digit_characters(phone_number)
  clean_number = phone_number.split("").map do |character|
    if is_digit?(character)
      character
    else
      next
    end
  end
  clean_number.join
end

def phone_number_is_valid?(phone_number)
  return true if phone_number.length == 10
  return false if phone_number.length < 10 || phone_number.length > 11
  return true if phone_number[0] == "1"
  return false if phone_number[0] != "1"
end

def clean_phone_number(phone_number)
  phone_number = remove_non_digit_characters(phone_number)
  if phone_number_is_valid?(phone_number)
    return phone_number[1..10] if phone_number.length == 11
    return phone_number
  else
    return nil
  end
end

puts "Event Manager Initialized! Let's Go!"

contents = CSV.open('event_attendees.csv', headers: true, header_converters: :symbol)
template_letter = File.read('form_letter.erb')
erb_template = ERB.new(template_letter)

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])
  legislators = legislators_by_zipcode(zipcode)
  phone_number = clean_phone_number(row[:homephone])

  puts phone_number
  form_letter = erb_template.result(binding)
  save_thank_you_letters(id, form_letter)
  
end



