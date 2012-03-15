class Attendee
  attr_accessor :first_name, :last_name, :email_address
  attr_accessor :zipcode, :city, :state, :address
  attr_accessor :phone_number, :regdate

  def initialize(bit)
    self.first_name = !bit[:first_name].nil? ? bit[:first_name] : ""
    self.last_name = !bit[:last_name].nil? ? bit[:last_name] : ""
    self.email_address = bit[:email_address]
    self.zipcode = clean_zipcode(bit[:zipcode])
    self.city = !bit[:city].nil? ? bit[:city] : ""
    self.state = !bit[:state].nil? ? bit[:state].upcase : ""
    self.address = !bit[:street].nil? ? bit[:street] : ""
    self.phone_number = clean_phone_number(bit[:homephone])
    self.regdate = bit[:regdate]
  end

  def self.attribute_names_for_export(format)
    if format.downcase == "csv"
      base_list = %w{first_name last_name email_address}
      add_list = %w{zipcode city state street homephone regdate}
      return base_list + add_list
    else
      return nil
    end
  end

  def format_data_for_export(format)
    if format.downcase == "csv"
      dataz = []
      dataz << self.first_name << self.last_name << self.email_address
      dataz << self.zipcode << self.city << self.state << self.address
      dataz << self.phone_number << self.regdate
      return dataz
    else
      return nil
    end
  end

  private

  def clean_zipcode(old_zip)
    if !old_zip || old_zip.to_s.empty? || old_zip.to_s.length > 5
      zipcode = "00000"
    elsif old_zip.to_s.length == 5
      zipcode = old_zip
    elsif old_zip.to_s.length == 4
      zipcode = "0#{old_zip}"
    elsif old_zip.to_s.length == 3
      zipcode = "00#{old_zip}"
    elsif old_zip.to_s.length == 2
      zipcode = "000#{old_zip}"
    elsif old_zip.to_s.length == 1
      zipcode = "0000#{old_zip}"
    end
    return zipcode
  end

  def clean_phone_number(number)
    number.delete!(".")
    number.delete!(" ")
    number.delete!("-")
    number.delete!("(")
    number.delete!(")")
    if number.length == 10
      # Do Nothing
    elsif number.length == 11
      if number.start_with?("1")
        number = number[1..-1]
      else
        number = "0000000000"
      end
    else
      number = "0000000000"
    end
    return number
  end
end