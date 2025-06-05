# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Form Validation Tests' do
  describe 'LoginCredentials Form' do
    it 'HAPPY: should validate correct login credentials' do
      valid_params = { 'username' => 'testuser', 'password' => 'testpass123' }
      result = UCCMe::Form::LoginCredentials.new.call(valid_params)

      _(result.success?).must_equal true
      _(result.values[:username]).must_equal 'testuser'
    end

    it 'SAD: should fail with empty username' do
      invalid_params = { 'username' => '', 'password' => 'testpass123' }
      result = UCCMe::Form::LoginCredentials.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:username]).must_include 'must be filled'
    end

    it 'SAD: should fail with missing password' do
      invalid_params = { 'username' => 'testuser' }
      result = UCCMe::Form::LoginCredentials.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:password]).must_include 'is missing'
    end
  end

  describe 'Registration Form' do
    it 'HAPPY: should validate correct registration data' do
      valid_params = { 'username' => 'newuser123', 'email' => 'test@example.com' }
      result = UCCMe::Form::Registration.new.call(valid_params)

      _(result.success?).must_equal true
      _(result.values[:username]).must_equal 'newuser123'
      _(result.values[:email]).must_equal 'test@example.com'
    end

    it 'SAD: should fail with invalid email format' do
      invalid_params = { 'username' => 'newuser123', 'email' => 'invalid-email' }
      result = UCCMe::Form::Registration.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:email]).must_include 'is in invalid format'
    end

    it 'SAD: should fail with short username' do
      invalid_params = { 'username' => 'ab', 'email' => 'test@example.com' }
      result = UCCMe::Form::Registration.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:username]).must_include 'size cannot be less than 3'
    end

    it 'SAD: should fail with invalid username format' do
      invalid_params = { 'username' => 'user@name', 'email' => 'test@example.com' }
      result = UCCMe::Form::Registration.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:username]).must_include 'is in invalid format'
    end
  end

  describe 'Passwords Form' do
    it 'HAPPY: should validate matching passwords' do
      valid_params = { 'password' => 'password123', 'password_confirm' => 'password123' }
      result = UCCMe::Form::Passwords.new.call(valid_params)

      _(result.success?).must_equal true
    end

    it 'SAD: should fail with non-matching passwords' do
      invalid_params = { 'password' => 'password123', 'password_confirm' => 'different456' }
      result = UCCMe::Form::Passwords.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:password]).must_include 'Passwords do not match'
    end

    it 'SAD: should fail with short password' do
      invalid_params = { 'password' => '123', 'password_confirm' => '123' }
      result = UCCMe::Form::Passwords.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:password]).must_include 'size cannot be less than 8'
    end

    it 'SAD: should fail with missing password confirmation' do
      invalid_params = { 'password' => 'password123' }
      result = UCCMe::Form::Passwords.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:password_confirm]).must_include 'is missing'
    end
  end

  describe 'NewFolder Form' do
    it 'HAPPY: should validate correct folder data' do
      valid_params = { 'foldername' => 'My_Test_Folder', 'description' => 'Test description' }
      result = UCCMe::Form::NewFolder.new.call(valid_params)

      _(result.success?).must_equal true
      _(result.values[:foldername]).must_equal 'My_Test_Folder'
    end

    it 'HAPPY: should validate folder without description' do
      valid_params = { 'foldername' => 'TestFolder' }
      result = UCCMe::Form::NewFolder.new.call(valid_params)

      _(result.success?).must_equal true
    end

    it 'SAD: should fail with invalid folder name characters' do
      invalid_params = { 'foldername' => 'Invalid@Folder!' }
      result = UCCMe::Form::NewFolder.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:foldername]).must_include 'is in invalid format'
    end

    it 'SAD: should fail with empty folder name' do
      invalid_params = { 'foldername' => '' }
      result = UCCMe::Form::NewFolder.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:foldername]).must_include 'must be filled'
    end

    it 'SAD: should fail with too long description' do
      long_description = 'a' * 201 # 超過 200 字符
      invalid_params = { 'foldername' => 'TestFolder', 'description' => long_description }
      result = UCCMe::Form::NewFolder.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:description]).must_include 'size cannot be greater than 200'
    end
  end

  describe 'CollaboratorEmail Form' do
    it 'HAPPY: should validate correct email' do
      valid_params = { 'email' => 'collaborator@example.com' }
      result = UCCMe::Form::CollaboratorEmail.new.call(valid_params)

      _(result.success?).must_equal true
      _(result.values[:email]).must_equal 'collaborator@example.com'
    end

    it 'SAD: should fail with invalid email' do
      invalid_params = { 'email' => 'not-an-email' }
      result = UCCMe::Form::CollaboratorEmail.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:email]).must_include 'is in invalid format'
    end

    it 'SAD: should fail with empty email' do
      invalid_params = { 'email' => '' }
      result = UCCMe::Form::CollaboratorEmail.new.call(invalid_params)

      _(result.failure?).must_equal true
      _(result.errors[:email]).must_include 'must be filled'
    end
  end

  describe 'Form Helper Methods' do
    it 'should format validation errors correctly' do
      invalid_params = { 'username' => 'ab', 'email' => 'invalid' }
      result = UCCMe::Form::Registration.new.call(invalid_params)

      error_message = UCCMe::Form.validation_errors(result)
      _(error_message).must_be_kind_of String
      _(error_message).must_include 'username'
      _(error_message).must_include 'email'
    end

    it 'should extract message values correctly' do
      invalid_params = { 'password' => '123', 'password_confirm' => '456' }
      result = UCCMe::Form::Passwords.new.call(invalid_params)

      message_values = UCCMe::Form.message_values(result)
      _(message_values).must_be_kind_of String
      _(message_values.length).must_be :>, 0
    end
  end
end
