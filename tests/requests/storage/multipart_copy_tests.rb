require 'securerandom'

Shindo.tests('Fog::Storage[:aws] | copy requests', ["aws"]) do

  @directory = Fog::Storage[:aws].directories.create(:key => uniq_id('fogmultipartcopytests'))

  tests('copies an empty object') do
    Fog::Storage[:aws].put_object(@directory.identity, 'empty_object', '')

    file = Fog::Storage[:aws].directories.new(key: @directory.identity).files.get('empty_object')
    file.multipart_chunk_size = Fog::AWS::Storage::File::MIN_MULTIPART_CHUNK_SIZE

    tests("#copy_object('#{@directory.identity}', 'empty_copied_object'").succeeds do
      file.copy(@directory.identity, 'empty_copied_object')
    end

    copied = Fog::Storage[:aws].directories.new(key: @directory.identity).files.get('empty_copied_object')
    test("copied is the same") { copied.body == file.body }
  end

  tests('copies a small object') do
    Fog::Storage[:aws].put_object(@directory.identity, 'fog_object', lorem_file)

    file = Fog::Storage[:aws].directories.new(key: @directory.identity).files.get('fog_object')

    tests("#copy_object('#{@directory.identity}', 'copied_object'").succeeds do
      file.copy(@directory.identity, 'copied_object')
    end

    copied = Fog::Storage[:aws].directories.new(key: @directory.identity).files.get('copied_object')
    test("copied is the same") { copied.body == file.body }
  end

  tests('copies a file needing a single part') do
    data = '*' * Fog::AWS::Storage::File::MIN_MULTIPART_CHUNK_SIZE
    Fog::Storage[:aws].put_object(@directory.identity, '1_part_object', data)

    file = Fog::Storage[:aws].directories.new(key: @directory.identity).files.get('1_part_object')
    file.multipart_chunk_size = Fog::AWS::Storage::File::MIN_MULTIPART_CHUNK_SIZE

    tests("#copy_object('#{@directory.identity}', '1_part_copied_object'").succeeds do
      file.copy(@directory.identity, '1_part_copied_object')
    end

    copied = Fog::Storage[:aws].directories.new(key: @directory.identity).files.get('1_part_copied_object')
    test("copied is the same") { copied.body == file.body }
  end

  tests('copies a file with many parts') do
    data = SecureRandom.hex * 19 * 1024 * 1024
    Fog::Storage[:aws].put_object(@directory.identity, 'large_object', data)

    file = Fog::Storage[:aws].directories.new(key: @directory.identity).files.get('large_object')
    file.multipart_chunk_size = Fog::AWS::Storage::File::MIN_MULTIPART_CHUNK_SIZE

    tests("#copy_object('#{@directory.identity}', 'large_copied_object'").succeeds do
      file.copy(@directory.identity, 'large_copied_object')
    end

    copied = Fog::Storage[:aws].directories.new(key: @directory.identity).files.get('large_copied_object')

    test("copied is the same") { copied.body == file.body }
  end
end
