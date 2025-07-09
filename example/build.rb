require 'fileutils'

def run(cmd)
  puts cmd
  system(cmd) or abort("Failed #{cmd}")
end

FileUtils.mkdir_p("build")

files = [
  "main.c"
].join(" ")

args = [
  "#{files}",
  "-nostdlib",
  "-nostartfiles",
  "-nodefaultlibs",
  "-fno-builtin",
  "-ffreestanding",
  "-Iinclude/",
  "-lkcstd",
  "-o build/main",
].join(" ")

run("gcc #{args}")

HOME = ENV["HOME"]
FileUtils.mkdir_p("#{HOME}/temp/kcstd_example/")
FileUtils.cp("build/main", "#{HOME}/temp/kcstd_example/main")

Dir.chdir("#{HOME}/temp/kcstd_example") do
  run("chmod +x main")
  run("./main a b c")
end