# Utilities for providers
#
# Copyright (c) 2012 Dominic Cleal
# Licensed under the Apache License, Version 2.0

require 'augeas' if Puppet.features.augeas?
require 'augeasproviders'

module AugeasProviders::Provider
  def self.augopen(lens, file = nil)
    aug = nil
    begin
      aug = Augeas.open(nil, nil, Augeas::NO_MODL_AUTOLOAD)
      aug.transform(
        :lens => lens,
        :name => "AP",
        :incl => file
      )
      aug.load!

      if aug.match("/files#{file}").empty?
        message = aug.get("/augeas/files#{file}/error/message")
        fail("Augeas didn't load #{file}: #{message}")
      end
    rescue
      aug.close if aug
      raise
    end
    aug
  end

  def augsave!(aug)
    begin
      aug.save!
    rescue Augeas::Error
      errors = []
      aug.match("/augeas//error").each do |errnode|
        aug.match("#{errnode}/*").each do |subnode|
          subvalue = aug.get(subnode)
          errors << "#{subnode} = #{subvalue}"
        end
      end
      raise Augeas::Error, errors.join("\n")
    end
  end
end
