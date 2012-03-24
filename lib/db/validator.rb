class Chef
  module Dashboard
    class DB
      module Validator
        class << self

          def validate(obj, params)
            messages = []

            result = params.all? do |k, v| 
              indiv_result = case v
                             when "bool"
                               [TrueClass, FalseClass, NilClass].any? { |x| obj[k].kind_of?(x) }
                             else
                               obj[k].kind_of?(v)
                             end
              unless indiv_result
                messages.push("#{k} is not of type #{v}")
              end

              indiv_result
            end

            return result, messages
          end

          def validate_report(report)
            validate(
              report,
              {
                :resources  => Array,
                :success    => "bool",
                :fqdn       => String,
                :ipaddress  => String,
                :name       => String,
              }
            )
          end
        end
      end
    end
  end
end
