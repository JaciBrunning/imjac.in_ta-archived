require 'digest'
require 'thread'
require 'open-uri'
require 'net/http'

class WPIMirrorCache
  QUEUE_DEPTH = 40

  def initialize upstream, dump, limit
    @upstream = upstream
    @dump = dump
    @limit = limit
    @queue = []
    @thread = Thread.new do
      thread_func
    end

    FileUtils.mkdir_p dump
  end

  def cache_size
    Dir.glob(File.join(@dump, '**', '*'))
      .map{ |f| File.size(f) }
      .inject(:+)
  end

  def hash artifact_path
    Digest::MD5.hexdigest(artifact_path)
  end

  def process artifact_path
    extension = File.extname(artifact_path)
    base_artifact = File.dirname(artifact_path) + "/" + File.basename(artifact_path, extension)

    valid = !(extension.nil? || extension.empty?)
    remote_path = "#{@upstream}/#{artifact_path}"
    artifact_id = nil
    local = nil
    can_enqueue = true

    if extension == ".md5" || extension == ".sha1"
      # Is metadata
      artifact_id = hash(base_artifact)
      local = "#{@dump}/#{artifact_id}#{File.extname(base_artifact)}#{extension}"
      can_enqueue = false
    else
      # Is artifact
      artifact_id = hash(artifact_path)
      local = "#{@dump}/#{artifact_id}#{extension}"
    end

    exists = File.exist?(local)

    {
      asset_id: artifact_id,
      upstream: @upstream,
      remote: remote_path,
      local: local,
      enqueue: (valid && can_enqueue) ? !exists : false,
      redirect: valid && !exists,
      exists: exists
    }
  end

  def queue from, to
    obj = { from: from, to: to }
    if @queue.size > QUEUE_DEPTH
      puts "[WPI MIRROR] Skipping queue (queue limit)"
    else
      already_queued = @queue.include?(obj)
      if @queue.include? obj
        puts "[WPI MIRROR] Skipping queue (already queued)"
      else
        @queue << obj
        puts "[WPI MIRROR] Queued download (#{@queue.size - 1})"
      end
    end
  end

  # Thread

  def write_cache_hash file
    md5 = Digest::MD5.file(file).hexdigest
    sha1 = Digest::SHA1.file(file).hexdigest

    File.write("#{file}.md5", md5)
    File.write("#{file}.sha1", sha1)
  end

  def process_top
    top = @queue.shift
    puts "[WPI MIRROR] Processing (#{@queue.size}): #{top}"
    begin
      case io = open(top[:from])
      when StringIO then 
        IO.copy_stream(io, top[:to])
      when Tempfile then 
        FileUtils.mv(io.path, top[:to])
      end
      write_cache_hash top[:to]
    rescue OpenURI::HTTPError => e
      puts "[WPI MIRROR] HTTP Error (#{e.message}) #{top[:from]}"
    end
  end

  def thread_func
    while 1
      begin
        sz = cache_size
        unless !sz.nil? && sz > @limit
          process_top unless @queue.empty?
        else
          puts "[WPI MIRROR] Over size limit! Emptying queue. (#{sz})"
          @queue.clear
          sleep 30
        end
      rescue => e
        puts "[WPI MIRROR] Exception: #{e}"
      end
      sleep 1
    end
  end
end