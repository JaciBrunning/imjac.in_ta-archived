require 'thread'
require 'array_queue'

class Job
    attr_accessor :name

    def initialize name, &block
        @action = block
        @cancelled = false
        @name = name
    end

    def cancel
        @cancelled = true
    end

    def cancelled?
        @cancelled
    end

    def run
        @action.call() unless @cancelled
    end
end

class Jobs
    WORKER_COUNT = 2
    @jobs = ArrayQueue.new
    @current_jobs = []
    @current_jobs_mutex = Mutex.new

    def self.jobs
        @jobs
    end

    def self.current_jobs
        @current_jobs
    end

    def self.submit job_or_name, &block
        job = nil
        if job_or_name.is_a?(Job)
            job = job_or_name
        else
            job = Job.new(job_or_name.to_sym, &block)
        end
        puts "[JOBS] Submitting #{job.name}"
        @jobs.pushQ job
    end

    def self.start
        puts "[JOBS] Jobs Service Starting..."
        @workers = (0...WORKER_COUNT).map do |threadnum|
            Thread.new do
                puts "[JOB WORKER #{threadnum}] Started worker."
                while job = @jobs.popQ
                    begin
                        unless job.cancelled?
                            puts "[JOB WORKER #{threadnum}] Running job #{job.name}..."
                            @current_jobs_mutex.synchronize {
                                @current_jobs[threadnum] = job
                            }
                            
                            job.run()

                            @current_jobs_mutex.synchronize {
                                @current_jobs[threadnum] = nil
                            }
                            puts "[JOB WORKER #{threadnum}] Finished job #{job.name}!"
                        else
                            puts "[JOB WORKER #{threadnum}] Job #{job.name} cancelled! Not running.."
                        end
                    rescue => e
                        puts e
                    end
                end
                puts "[JOB WORKER #{threadnum}] Stopped worker."
            end
        end
    end
end