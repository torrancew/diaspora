#   Copyright (c) 2010-2011, Diaspora Inc.  This file is
#   licensed under the Affero General Public License version 3 or later.  See
#   the COPYRIGHT file.
#

module Jobs
  class ExportPhotos < Base
    @queue = :http_service

    def self.perform(user_person_id, archive_file_name)
      exporter = PhotoMover.new(user_person_id, archive_file_name)
      exporter.generate_tarball
    end
  end
end
