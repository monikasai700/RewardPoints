require 'pry'
require 'json'
require 'date'
class RewardPoints
    def process
        @customers = {}
        file = File.open("sample.json", 'r') # Opening  a json file
        file_read = file.read 
        if file_read == "" # checking file input
            print "File is empty or no records to process."
        else
            file_data = JSON.parse(file_read) # parsing the file data which is in json format
            file_data["events"].each do |item|
                if item["action"] == "new_customer"
                    add_customer(item)
                elsif item["action"] == "new_order"
                    calculate_points(item)
                else
                    print("No data to process")
                end
            end
            display_results()
        end
    end
    # Adds customer to the customer object.
    def add_customer(item)
        new_customer = item["name"]!= nil ? item["name"] : item["customer"]
        @customers[new_customer]= {}
        @customers[new_customer][:total_amount] = 0
        @customers[new_customer][:orders] = 0
        @customers[new_customer][:points] = 0
    end
    # Calculates reward points based on the customer orders.
    def calculate_points(item)
        if @customers.include?(item["customer"])
            time_of_order = DateTime.parse(item["timestamp"])
            customer = @customers[item["customer"]]
            customer[:total_amount]= customer[:total_amount] + item["amount"]

            # Reward points calculation based on the schedule
            if (time_of_order.hour >= 12 && time_of_order.hour < 13)
                temp_points = (item["amount"]/3).ceil
            elsif (time_of_order.hour >= 11 && time_of_order.hour < 12) || (time_of_order.hour >= 13 && time_of_order.hour < 14)
                temp_points = (item["amount"]/2).ceil
            elsif (time_of_order.hour >= 10 && time_of_order.hour < 11) || (time_of_order.hour >= 14 && time_of_order.hour < 15)
                temp_points = (item["amount"]).ceil
            else
                temp_points = (item["amount"]*0.25).ceil
            end
            if (temp_points >= 3 && temp_points < 21)
                customer[:orders] = customer[:orders] + 1
                customer[:points] =  customer[:points] + temp_points
            end
            
            customer[:average_points] = (customer[:points]/customer[:orders])
        else
            add_customer(item)
        end
    end
    # Displays the results from the customers object.
    def display_results()
        @customers = @customers.sort_by{ |customer,values| values[:points] }.reverse
        @customers.map { |customer,values|
            if values[:total_amount] > 0
                print("#{customer}: #{values[:points]} points with #{values[:average_points]} points per order. \n")
            else
                print("#{customer}: No orders.\n")
            end
        }
    end
end

rp = RewardPoints.new
rp.process()