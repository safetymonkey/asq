# Class used for providing archived files to the user
class ArchivedFilesController < ApplicationController
  def show
    @file = ArchivedFile.find(params[:id])
    generate_csv
  rescue StandardError => e
    logger.error 'Unable to render archive file ' \
      "(id: #{params[:id]}: #{e}"
    render body: nil
  end

  private

  def generate_csv
    send_file(
      @file.full_path,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment; filename=\"#{@file.name}\""
    )
  end
end
