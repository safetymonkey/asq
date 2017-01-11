class StaticPagesController < ApplicationController
  def home
  end

  def help
    @title = 'Help'
  end

  def tag_cloud
    gon.view = 'static_pages#tag_cloud'
    # format for tag cloud array [{text: "tag", weight: 5, link: "this"}]
    @asq = Asq.first
    @tags = Asq.tag_counts_on(:tags)

    tag_array = []

    @tags.each do |tag|
      name = tag.name
      tag_link = tags_path(tag.name)
      uri = URI.unescape(tag_link)
      weight = tag.taggings_count
      tag_array.push(text: name, weight: weight, link: uri)
    end

    gon.tag_array = tag_array
    gon.view = 'static_pages#tag_cloud'
  end
end
