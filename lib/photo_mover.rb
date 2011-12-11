require 'open-uri'

class PhotoMover

  def initialize(user_id)
    @user = User.find_by_id(user_id)
  end

  def generate_tarball
    Dir.chdir Rails.root
    temp_dir = "tmp/exports/#{@user.id.to_s}"
    FileUtils::mkdir_p temp_dir
    Dir.chdir 'tmp/exports'

    photos = @user.photos

    photos_dir = "#{@user.id.to_s}/photos"
    FileUtils::mkdir_p photos_dir

    photos.each do |photo|
      current_photo_location = photo.url
      new_photo_location     = "#{photos_dir}/#{photo.remote_photo_name}"

      File.open(new_photo_location, 'w') { |f|
        OpenURI.open_uri(current_photo_location) { |uri| f.write(uri.read) }
      }
    end

    `tar c #{@user.id.to_s} > #{@user.id}.tar`
    #system("tar", "c", "#{user.id}",">", "#{user.id}.tar")
    FileUtils::rm_r "#{@user.id.to_s}/", :secure => true, :force => true

    "#{Rails.root}/#{temp_dir}.tar"
  end
end
