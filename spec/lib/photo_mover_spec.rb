#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.

require 'spec_helper'
#require File.join(File.dirname(__FILE__), '..', '..', 'lib', 'photo_mover')
require File.join(Rails.root, 'lib', 'photo_mover')

describe PhotoMover do
  before do
    @user_id      = alice.id
    @archive_name = 'foo.tar'
    @exporter     = PhotoMover.new(@user_id, @archive_name)

    @pub_dir = File.join(Rails.root, 'public', 'exports')
    @tmp_dir = File.join(Rails.root, 'tmp', 'exports')
  end

  describe '#setup_directories' do
    before { @exporter.setup_directories }

    it 'ensures the published directory exists' do
      # Call PhotoMover#setup_directories
      # Confirm presence of public/exports
      File.directory?(@pub_dir).should == true
    end

    it 'ensures the temporary directory exists' do
      # Call PhotoMover#setup_directories
      # Confirm presence of tmp/exports/@user.id/photos
      File.directory?(@tmp_dir).should == true
    end
  end

  describe '#generate_tarball' do
    it 'creates a tarball' do
      pending
    end
  end

  describe '#copy_photo' do
    it 'copies the the photo to the temporary directory' do
      pending
    end
  end

  describe '#cleanup_tmp_files' do
    it 'removes the temporary directory' do
      pending
    end
  end
end
