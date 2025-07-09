require 'fileutils'
require 'rbconfig'

def run(cmd)
  system(cmd) or abort("Failed to run #{cmd}")
end

def help()
  puts "KCStd Buildscript"
  puts "--install or -i   | Installs after build."
  puts "--clean or -c     | Clean files before build."
  puts "--help or -h      | Shows helps."
  exit 1
end

def install()
  prefix = ENV["PREFIX"]
  FileUtils.cp("build/libkcstd.a", "#{prefix}/lib/libkcstd.a")
  puts "-- Installing #{prefix}/lib/libkcstd.a"
  FileUtils.mkdir_p("#{prefix}/include/kcstd")
  Dir.glob("include/kcstd/*").each do |header|
    header_filename = header.split("/").last
    out_dir = "#{prefix}/include/kcstd/#{header_filename}"
    puts "-- Installing #{out_dir}"
    FileUtils.cp_r(header, out_dir)
  end
end

arch = case RbConfig::CONFIG['host_cpu']
  when "x86"     then :x86
  when "x86_64"  then :x86_64
  when "aarch64" then :aarch64
  when "i686"    then :arm
  else           :unknown
end

if arch == :unknown
  puts "Unknown architeture"
  exit(1)
end

puts "-- Building in #{arch}"

asmbuild_args = [
  "-nostdlib",
  "-nodefaultlibs",
  "-c -fPIC"
].join(" ")

cbuild_args = [
  "-std=c99",
  "-nostdlib",
  "-nodefaultlibs",
  "-fno-builtin",
  "-ffreestanding",
  "-static",
  "-Iinclude/"
].join(" ")

install_arg = false

if ARGV.length >= 1
  ARGV.each do |arg|
    case arg
      when "-h", "--help"
        help()
      when "-i", "--install"
        install_arg = true
      when "-c", "--clean"
        FileUtils.remove_dir("build")
    end
  end
end

FileUtils.mkdir_p("build")

# Compile All Assembly Sources
Dir.glob("src/asm/#{arch}/*.s").each do |file|
  obj = "build/#{File.basename(file, '.s')}.o"
  temp_file = "build/#{File.basename(file, '.s')}_temp.s"

  # Skip file if last build file content is equal current
  it_content = File.read(file)
  if File.exist?(temp_file)
    temp_file_content = File.read(temp_file)
    if temp_file_content == it_content
      next
    else
      File.write(temp_file, it_content)
    end
  else
    File.write(temp_file, it_content)
  end

  # Compile
  puts "-- Compiling #{file}..."
  run("gcc #{asmbuild_args} -c #{file} -o #{obj}")
end

# Compile All C Sources
Dir.glob("src/*.c").each do |file|
  obj = "build/#{File.basename(file, '.c')}.o"
  temp_file = "build/#{File.basename(file, '.c')}_temp.c"

  # Skip file if last build file content is equal current
  it_content = File.read(file)
  if File.exist?(temp_file)
    temp_file_content = File.read(temp_file)
    if temp_file_content == it_content
      next
    else
      File.write(temp_file, it_content)
    end
  else
    File.write(temp_file, it_content)
  end

  # Compile
  puts "-- Compiling #{file}..."
  run("gcc #{cbuild_args} -c #{file} -o #{obj}")
end

puts "-- Compiled successfully!"

if install_arg
  objects = Dir.glob("build/*.o").join(" ")
  run("ar rcs build/libkcstd.a #{objects}")
  install()
end