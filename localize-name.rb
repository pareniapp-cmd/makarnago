# Ana ekrandaki uygulama adını cihaz diline göre değiştirir (en iyi çaba: başarısız olursa derleme yine geçer).
require 'xcodeproj'
require 'fileutils'
begin
  names = { 'en' => 'Pasta Escape', 'tr' => 'Makarna Kaçış', 'es' => 'Fuga de Pasta', 'pt-BR' => 'Fuga da Massa', 'ru' => 'Побег макаронины' }
  proj = Xcodeproj::Project.open('ios/App/App.xcodeproj')
  target = proj.targets.find { |t| t.name == 'App' }
  group = proj.main_group['App'] || proj.main_group.new_group('App', 'App')
  vg = group.new_variant_group('InfoPlist.strings')
  names.each do |l, n|
    dir = "ios/App/App/#{l}.lproj"
    FileUtils.mkdir_p(dir)
    File.write("#{dir}/InfoPlist.strings", "\"CFBundleDisplayName\" = \"#{n}\";\n")
    ref = vg.new_reference("#{l}.lproj/InfoPlist.strings")
    ref.name = l
  end
  target.resources_build_phase.add_file_reference(vg)
  proj.root_object.known_regions = (proj.root_object.known_regions + names.keys).uniq
  proj.save
  puts 'ana ekran adı yerelleştirildi'
rescue => e
  puts "yerelleştirme atlandı: #{e.message}"
end
exit 0
