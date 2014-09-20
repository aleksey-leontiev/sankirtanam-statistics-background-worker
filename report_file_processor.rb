# encoding:utf-8

# processes xls, xlsx files and retrieves
# sankirtanam statistics data from it
class ReportFileProcessor
  # processes file using specified path
  def process_file(path)
    result = []                  # result hash
    book   = open_workbook(path) # open workbook
    
    book.sheets.each do |sheet|  # process each sheet
      book.default_sheet = sheet
      version            = get_version(book)

      if version != -1 then
        result << { meta: get_metadata(book, version, path),
                    data: get_data(book, version) }
      else
        result << { meta: { error: "e01: Unable to determine file version" } }
      end
    end

    result
  end

  # gets version of data representation for specified sheet
  def get_version(sheet)
    begin
      # no data to determine verson by
      if sheet.nil? then return -1 end
      if sheet.last_row.nil? then return -1 end
      if sheet.row(1).nil? then return -1 end
      if sheet.row(1)[0].nil? then return -1 end
      
      # version 1 checks
      if sheet.row(1)[0] == "имя" then return 1 end
      if sheet.row(1)[0] == "name" then return 1 end
      
      # version 2 checks
      if sheet.row(1)[0].start_with?("Правила") then return 2 end
    rescue
    end

    -1 # unable to determine
  end

  # returns metadata from specified sheet using version and path
  def get_metadata(sheet, version, path)
    case version
    when 1
      filename = File.basename(path, ".*")
      return {
        version:  1,
        location: filename[0..-9],
        month:    filename[-7, 2],
        year:     filename[-4, 4]}
    
    when 2
      row = sheet.row(2)
      return {
        version:  version,
        location: row[0],
        month:    row[2],
        year:     row[4]}
    
    else
      return { error: "Unable to get metadata for version specified"}
    end
  end

  # returns statistic data for sheet specified
  def get_data(sheet, version)
    result = []
    start  = version == 2 ? 4 : 2
    (start..sheet.last_row).each do |i|
      row = sheet.row(i)
      
      if row_is_wrong(row) then next end

      result << {
        name:    row[0],
        huge:    row[1] || 0,
        big:     row[2] || 0,
        medium:  row[3] || 0,
        small:   row[4] || 0}
    end
    result
  end

  # opens workbook by path specified
  def open_workbook(path)
    case File.extname(path)
      when '.xls'  then Roo::Excel.new(path)
      when '.xlsx' then Roo::Excelx.new(path)
      else raise "Unknown file type: #{path}"
    end
  end

  #
  def row_is_wrong(row)
    row[0] == nil || row[0] == "" || row[0] == "Итого"
  end
end