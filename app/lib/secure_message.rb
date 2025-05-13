require 'base64'
require 'rbnacl'

class SecureMessage
    class << self 
        attr_reader :key
        
        def encoded_random_bytes(length)
            bytes = RbNaCl::Random.random_bytes(length)
            Base64.strict_encode64 bytes 
        end 

        def generate_key 
            encoded_random_bytes(RbNaCl::SecretBox.key_bytes)
        end 

        def setup(msg_key)
            @key = Base64.strict_decode64(msg_key)
        end 

        def encrypt(message)
            raise 'message missing' unless message 

            message_json = message.to_json 
            simple_box = RbNaCl::SimpleBox.from_secret_key(self.class.key)
            message_json = simple_box.decrypt(ciphertext)
            JSON.parse(message_json)
        end 
    end 
    

    