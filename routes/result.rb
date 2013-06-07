def load_results(ids)
  if ids.empty?
    []
  else
    $redis.mget(*ids.map { |id| "result-#{id}" })
  end
end


get '/results' do
  unless session[:flash].nil?
    @flash = session[:flash]
    session[:flash] = nil
  end

  @results = $redis.sort "all-results", :order => "DESC", :limit => [0, 100]
  haml :results
end

get '/results/:id' do
  @job_id = params[:id].to_i
  @result = load_results([@job_id]).map {|result| JSON.parse(result) }.first
  haml :result
end

