require 'csv'
require_relative 'error_handler'

# ##
# Performs below set of processing on input CSV file.
# -Format line endings i.e., convert line endings into UNIX style \n format
# -Removes any 'nulls', '\N', '',"",, and replaces them with NULL for easier import into Database
# -Removes any quotings around numbers
# -Coverts single quotes into double quotes if they are used as field encapsulations
# -creates another file with file name prepended by 'processed_'
# ##
class CSVCleaner
	
	def cleaner_csv(filename,delimiter,processed_file_name)
		#delimiter = "\\|" if delimiter == '|'
		if File::exists?(filename)
			output = processed_file_name
			csvwrite = CSV.open(output, "wb", {:col_sep => delimiter})

		    #Check if user wants to replace empty spaces null references to NULL
			puts "Do you want replace any empty spaces or Null's or \\N with NULL?"
			puts "Enter Yes or No"
			replace_nulls = gets.chomp.upcase
			replace_nulls = "YES" if replace_nulls == "Y"
		     replace_nulls = "NO" if replace_nulls == "N"
			while replace_nulls != "YES" && replace_nulls != "NO"
		      puts "Invalid input!! Enter either yes or no"
		      replace_nulls = gets.chomp.upcase
		      replace_nulls = "YES" if replace_nulls == "Y"
		      replace_nulls = "NO" if replace_nulls == "N"
		    end

		    #check if user wants to convert single quotes to double quotes
		    puts "Do you want to convert single quotes to double quotes"
			puts "Enter Yes or No"
			replace_quotes = gets.chomp.upcase
			replace_quotes = "YES" if replace_quotes == "Y"
		      replace_quotes = "NO" if replace_quotes == "N"
			while replace_quotes != "YES" && replace_quotes != "NO" && replace_quotes != "N" && replace_quotes != "Y"
		      puts "Invalid input!! Enter either yes or no"
		      replace_quotes = gets.chomp.upcase
		      replace_quotes = "YES" if replace_quotes == "Y"
		      replace_quotes = "NO" if replace_quotes == "N"
		    end

		    if(replace_nulls == "YES" && replace_quotes == "YES")
				File.foreach(filename) do |line|
					line = replace_line_single_quotes(line,delimiter)
					begin
						line = CSV.parse_line(line, {:col_sep => delimiter})
					rescue CSV::MalformedCSVError => error
						puts error
						puts line
						puts "Please correct the above line and re-enter"
						line = gets.chomp
						line = CSV.parse_line(line, {:col_sep => delimiter})
					end
					#line = replace_line_endings(line)
					line = replace_line_nulls(line)
					#line = remove_quotes_around_numbers(line)
					csvwrite << line
				end
			elsif(replace_nulls == "YES" && replace_quotes == "NO")
				File.foreach(filename) do |line|
					begin
						line = CSV.parse_line(line, {:col_sep => delimiter})
					rescue CSV::MalformedCSVError => error
						puts error
						puts line
						puts "Please correct the above line and re-enter"
						line = gets.chomp
						line = CSV.parse_line(line, {:col_sep => delimiter})
					end
					line = replace_line_nulls(line)
					csvwrite << line
				end
			else
				File.foreach(filename) do |line|
					line = replace_line_single_quotes(line,delimiter)
					begin
						line = CSV.parse_line(line, {:col_sep => delimiter})
					rescue CSV::MalformedCSVError => error
						puts error
						puts line
						puts "Please correct the above line and re-enter"
						line = gets.chomp
						line = CSV.parse_line(line, {:col_sep => delimiter})
					end
					csvwrite << line
				end
			end
			csvwrite.close
		else
			FileNotFound.new
		end
	end

	def replace_line_single_quotes(line,delimiter)
		delimiter = "\\|" if delimiter == "|"
		pattern = "#{delimiter}'.*?'#{delimiter}"
		puts pattern
		res = line.gsub(/#{pattern}/)
		result = res.each { |match|
			replace = "#{delimiter}\""
			replace = "\|\"" if delimiter == "\\|"
			match = match.gsub(/^#{delimiter}'/,replace)
			replace = "\"#{delimiter}"
			replace = "\"\|" if delimiter == "\\|"
			match = match.gsub(/'#{delimiter}$/,replace)
		}
		#puts result
		#result = result.gsub(/\\|/,'|')
		result = result.gsub(/''/,'\'')

		return result
	end

	def replace_line_nulls(line)
		line.each do |value|
            if(value == nil || value == "\\N" || value == "nil" ||value == "")
              replace_index = line.index(value)
              line[replace_index] = "NULL"
            end
        end
        return line
	end
	
end
