begin
  PaymentEngine.new(Dune::Balanced::Bankaccount::Interface.new).save
rescue Exception => e
  puts "Error while registering payment engine: #{e}"
end
