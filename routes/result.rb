
get '/results' do
  haml :result
end

get '/results/:id' do

  @index = params[:id].to_i
  
  @result = JSON.parse(File.read("/tmp/#{@index}.json"))

  haml :result

end

