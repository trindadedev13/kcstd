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
    FileUtils.cp(header, out_dir)
  end
end

def should_compile?(src, temp)
  content = File.read(src)
  if File.exist?(temp)
    return false if File.read(temp) == content
  end
  File.write(temp, content)
  true
end

arch = case RbConfig::CONFIG['host_cpu']
  when "x86", "i386", "i686" then :x86
  when "x86_64", "amd64"     then :x86_64
  when "aarch64"             then :aarch64
  when "arm", "armv7l"       then :arm
  else                       :unknown
end

if arch == :unknown
  puts "Unknown architeture"
  exit(1)
end

puts "-- Building in #{arch}"

asmbuild_args = [
  "-nostdlib",
  "-nodefaultlibs",
  "-c",
  "-fPIC"
]

cbuild_args = [
  "-std=c99",
  "-nostdlib",
  "-nodefaultlibs",
  "-fno-builtin",
  "-ffreestanding",
  "-static",
  "-Iinclude/"
]

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
      when "-x32", "--x86"
        arch = :x86
        cbuild_args.push("-m32")
        asmbuild_args.push("-m32")
      when "-x64", "--x86_64"
        arch = :x86_64
        cbuild_args.push("-m64")
        asmbuild_args.push("-m64")
    end
  end
end

FileUtils.mkdir_p("build")

# Compile All Assembly Sources
Dir.glob("src/asm/#{arch}/*.s").each do |file|
  obj = "build/#{File.basename(file, '.s')}.o"
  temp_file = "build/#{File.basename(file, '.s')}_temp.s"

  # Skip file if last build file content is equal current
  next unless should_compile?(file, temp_file)

  # Compile
  puts "-- Compiling #{file}..."
  run("gcc #{asmbuild_args.join(' ')} -c #{file} -o #{obj}")
end

# Compile All C Sources
Dir.glob("src/*.c").each do |file|
  obj = "build/#{File.basename(file, '.c')}.o"
  temp_file = "build/#{File.basename(file, '.c')}_temp.c"

  # Skip file if last build file content is equal current
  next unless should_compile?(file, temp_file)

  # Compile
  puts "-- Compiling #{file}..."
  run("gcc #{cbuild_args.join(' ')} -c #{file} -o #{obj}")
end

objects = Dir.glob("build/*.o").join(" ")
 run("ar rcs build/libkcstd.a #{objects}")

puts "-- Compiled successfully!"

install() if install_arg