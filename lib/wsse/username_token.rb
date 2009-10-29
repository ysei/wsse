# coding: utf-8

require "time"
require "digest/sha1"

module Wsse
  class UsernameToken
    def initialize(username, digest, nonce, created)
      @username = username
      @digest   = digest  # binary
      @nonce    = nonce   # binary
      @created  = created # Time object
    end

    attr_reader :username, :digest, :nonce, :created

    def self.create_random_binary(size)
      return size.times.map { rand(256) }.pack("C*")
    end

    def self.create_password_digest(password, nonce, created)
      return Digest::SHA1.digest(nonce + created.utc.iso8601 + password)
    end

    def self.build(username, password, nonce = nil, created = nil)
      nonce   ||= self.create_random_binary(20)
      created ||= Time.now.utc
      digest = self.create_password_digest(password, nonce, created)
      return self.new(username, digest, nonce, created)
    end

    def self.format_token_values(username, digest, nonce, created)
      return format(
        %|UsernameToken Username="%s", PasswordDigest="%s", Nonce="%s", Created="%s"|,
        username, digest, nonce, created)
    end

    def base64encoded_digest
      return [@digest].pack("m").chomp
    end

    def base64encoded_nonce
      return [@nonce].pack("m").chomp
    end

    def format
      return self.class.format_token_values(
        self.username,
        self.base64encoded_digest,
        self.base64encoded_nonce,
        self.created.utc.iso8601)
    end

    # TODO: self.parse(token) -> UsernameToken
    # TODO: self.parse_time(time) -> Time
  end
end
