$LOAD_PATH << './'
require 'csv'
require 'attendee'

class EventReporter

  ALL_COMMANDS = {"load" => "loads a new file",
    "help" => "shows a list of available commands",
    "queue count" => "total items in the queue",
    "queue clear" => "empties the queue",
    "queue print" => "prints to the queue",
    "queue print by" => "prints the specified attribute",
    "queue save to" => "exports queue to a CSV",
    "find" => "load the queue with matching records"}

  def initialize
    clear_queue
  end

  def run_user_prompt
    inputs = ""
    while inputs
      inputs = get_input
      command = inputs.first.nil? ? "exit" : inputs.first.downcase
      parameters = inputs[1..-1]
      case command
        when "help" then display_help_topics(parameters)
        when "load" then load_file(parameters)
        when "find" then load_query(parameters)
        when "queue" then handle_queue_command(parameters)
        when "quit" then exit
        when "exit" then exit
        else puts "The command #{command} is not a valid command."
      end
    end
  end

  def load_file(user_file)
    filename = user_file.empty? ? "event_attendees.csv" : user_file.first
    puts "loading file #{filename}"
    file = CSV.open(filename, :headers => true, :header_converters => :symbol)
    @master_list = file.collect { |line| Attendee.new(line) }
    puts "file loaded: #{@master_list.count} people found"
  end

  def get_input
    print "enter your command:\t"
    gets.strip.split(" ")
  end

  def load_query(query_params)
    attribute = query_params.first
    criteria = query_params[1..-1].join(" ")
    unless @master_list.nil?
      @the_queue = @master_list.select do |attendee|
        attendee.send(attribute).downcase == criteria.downcase
      end
      display_queue_count
    else
      puts "The attribute #{attribute} does not exist."
    end
  end

  def handle_queue_command(cmd_params)
    if cmd_params.first.downcase.eql?("clear")
      clear_queue
      display_queue_count
    elsif cmd_params.first.downcase.eql?("count")
      display_queue_count
    elsif cmd_params.first.downcase.eql?("print")
      display_queue(cmd_params[1..-1])
    elsif cmd_params[0..1].join(" ").downcase.eql?("save to")
      save_queue_to(cmd_params[2])
    end
  end

  def clear_queue
    @the_queue = []
  end

  def display_queue(parameters)
    unless @the_queue.empty?
      queue_copy = parameters.any? ? sort_queue_by(parameters[1]) : @the_queue
      puts "LAST NAME\tFIRST NAME\tEMAIL\tZIPCODE\tCITY\tSTATE\tADDRESS\tPHONE"
      queue_copy.each do |person|
        puts generate_attendee_print_output(person)
      end
    else
      puts "the queue is empty.  there is nothing to print."
    end
  end

  def generate_attendee_print_output(person)
    output="#{person.last_name}\t#{person.first_name}"
    output+="\t#{person.email_address}\t#{person.zipcode}\t#{person.city}"
    output+="\t#{person.state}\t#{person.address}\t#{person.phone_number}"
    return output
  end

  def display_queue_count
    puts "There are now #{@the_queue.count} records in the queue."
  end

  def save_queue_to(filename)
    csv_file = CSV.open("./#{filename}", "wb")
    csv_file << Attendee.attribute_names_for_export("csv")
    unless @the_queue.empty?
      @the_queue.each do |record|
        csv_file << record.format_data_for_export("csv")
      end
    end
    csv_file.close
    puts "saved queue to csv file -> #{filename}"
  end

  def sort_queue_by(attribute)
    return @the_queue.sort_by{|record| record.send(attribute)}
  end

  def display_help_topics(parameters)
    if parameters.any?
      command = parameters.join(" ")
      if ALL_COMMANDS.include?(command)
        puts "#{command}\t#{ALL_COMMANDS[command]}"
      else
        puts "The command #{command} does not exist."
      end
    else
      ALL_COMMANDS.each { |command| puts "#{command[0]}\t#{command[1]}" }
    end
  end
end

#script
er = EventReporter.new
er.run_user_prompt