# Create table that adapts column width to longest string in column
# Input:
# - Array of arrays (sub-array is one row)
# - Boolean (optional, indicating header row)
# Return:
# - nil
# Ouput:
# - Formatted text table

module TextTable
  CONNECTOR = '+'
  H_SPACER = '-'
  V_SPACER = '|'

  def self.number_of_columns(rows) # => integer
    rows.max { |a, b| a.size <=> b.size }.size
  end

  def self.column_widths(rows) # => array of integers
    widths = []

    number_of_columns(rows).times do |column|
      column_content_sizes = rows.map { |row| row[column].to_s.length }
      widths << column_content_sizes.max
    end

    widths
  end

  def self.create_line(column_widths) # => string
    line = column_widths.map { |length| H_SPACER * (length + 2) }
    CONNECTOR + line.join(CONNECTOR) + CONNECTOR
  end

  def self.add_columns(row, add_num) # => array
    array = row.dup
    add_num.times { array << '' }
    array
  end

  def self.justify(row, widths) # => array
    row.map.with_index { |element, i| element.to_s.ljust(widths[i]) }
  end

  def self.format_row(row, num_columns, widths) # => array
    difference = num_columns - row.size
    row = add_columns(row, difference) if difference > 0
    justify(row, widths)
  end

  def self.display_rows(rows, h_line, first_row_header)
    puts h_line # first line

    rows.each.with_index do |row, index|
      puts "#{V_SPACER} #{row.join(' ' + V_SPACER + ' ')} #{V_SPACER}"
      puts h_line if index == 0 && first_row_header
    end

    puts h_line # last line
  end

  def self.display(rows, first_row_header = false)
    num_columns = number_of_columns(rows)
    widths = column_widths(rows)
    h_line = create_line(widths)
    formatted_rows = rows.map { |row| format_row(row, num_columns, widths) }

    display_rows(formatted_rows, h_line, first_row_header)
  end
end

rows = [[1, 'cat', 'dog'],
        [2, 'cup', 'rainbow'],
        [3, 'computer', 'car', 'boat'],
        [4, 'chair']]

TextTable.display(rows, true)
puts ''
TextTable.display(rows)
puts ''

TextTable.display([['This is one cell']])
