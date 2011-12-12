require 'open-uri'

class PhotoMover

  def initialize(user_id, archive_name)
    @user          = User.find_by_id(user_id)
    @archive_name  = archive_name

    @pub_dir        = File.join(Rails.root, 'public', 'exports')
    @tmp_dir        = File.join(Rails.root, 'tmp', 'exports')
    @tmp_user_dir   = File.join(@tmp_dir, @user.id.to_s)
    @tmp_photos_dir = File.join(@tmp_user_dir, 'photos')
  end

  def setup_directories
    FileUtils::mkdir_p @pub_dir
    FileUtils::mkdir_p @tmp_photos_dir
  end

  def copy_photo(photo)
    current_location = photo.url
    new_path         = File.join(@tmp_photos_dir, photo.remote_photo_name)
    
    File.open(new_path, 'w') do |f|
      OpenURI.open_uri(current_location) { |uri| f.write(uri.read) }
    end
  end

  def generate_tarball
    setup_directories

    @user.photos.each do |photo|
      copy_photo photo
    end

    Dir.chdir @tmp_dir do
      `tar c #{@user.id.to_s} > #{File.join(@pub_dir, @archive_name)}`
    end

    cleanup_tmp_files
  end

  def cleanup_tmp_files
    FileUtils::rm_r @tmp_user_dir, :secure => true, :force => true
  end

end
