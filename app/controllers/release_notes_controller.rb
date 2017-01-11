class ReleaseNotesController < ApplicationController
  def index
    if current_user
      start_note = current_user.last_release_note_viewed
    else
      start_note = 0
    end

    release_notes = ReleaseNotes.new(start_note)
    @notes = content_to_array(release_notes.notes)

    if current_user && @notes.empty?
      current_user.last_release_note_viewed = release_notes.notes.first[:id]
      current_user.save
    end
  end

  def content_to_array(notes)
    display_array = []
    notes.each do |note|
      html = Markdown.new(File.read(note[:file])).to_html
      date = note[:date]
      id = note[:id]
      display_array.push({ title: note[:title], html: html, date: date, id: id,
                           unread: note[:unread] })
    end
    display_array
  end
end
