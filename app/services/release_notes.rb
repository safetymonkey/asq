class ReleaseNotes
  def initialize(last_release_read = 0)
    raise 'positive integer required' unless
      (last_release_read.is_a? Integer) || last_release_read < 0
    @last_release_read = last_release_read
    @notes = []
    @old_notes = []
    get_release_notes
  end

  def has_notes?
    !@notes.empty? && @notes.first[:unread]
  end

  def notes
    @notes
  end

  def get_release_notes
    @notes = []
    files = Dir.glob(Rails.root.join('release_notes', '*.md'))
    files.sort!.reverse!

    files.each do |file|
      file_base = File.basename(file)
      if file_base =~ /[0-9]{8}-[a-zA-z0-9\-]+\.md/
        note_id = file_base[0, 8].to_i
        note_date = Date.parse(file_base[0, 8]).strftime('%b %-d, %Y')           
        note_title = file_base.match(/([a-z][\-a-z]+[a-z])/).to_s
                     .tr('-', ' ').titleize
        @notes.push(id: note_id, date:note_date, title: note_title, file: file,
                    unread: note_id > @last_release_read)
      end
    end
  end
end
