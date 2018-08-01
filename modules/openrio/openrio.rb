class OpenRIOModule < WebcoreApp()
    get "/*" do
        [404, {}, "Not Found"]
    end
end