# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data
puts "Clearing existing data..."
Job.destroy_all
Hospital.destroy_all
User.where(role: :hospital).destroy_all

# Create hospital users and hospitals
puts "Creating hospital users and hospitals..."

hospital_data = [
  {
    name: "서울대학교치과병원",
    address: "서울특별시 종로구 대학로 101",
    phone: "02-2072-2175",
    email: "admin@snudh.com"
  },
  {
    name: "강남세브란스치과",
    address: "서울특별시 강남구 언주로 211",
    phone: "02-2019-3560",
    email: "admin@gseverance.com"
  },
  {
    name: "연세대학교치과대학병원",
    address: "서울특별시 서대문구 연세로 50-1",
    phone: "02-2228-3100",
    email: "admin@yuhs.ac"
  },
  {
    name: "이대목동병원치과",
    address: "서울특별시 양천구 안양천로 1071",
    phone: "02-2650-2570",
    email: "admin@eumc.ac.kr"
  },
  {
    name: "부산대학교치과병원",
    address: "부산광역시 서구 구덕로 179",
    phone: "051-240-7000",
    email: "admin@pusan.ac.kr"
  },
  {
    name: "분당서울대병원치과",
    address: "경기도 성남시 분당구 구미로 173번길 82",
    phone: "031-787-7000",
    email: "admin@snubh.org"
  },
  {
    name: "삼성서울병원치과",
    address: "서울특별시 강남구 일원로 81",
    phone: "02-3410-2114",
    email: "admin@samsung.com"
  },
  {
    name: "아산병원치과",
    address: "서울특별시 송파구 올림픽로43길 88",
    phone: "02-3010-3114",
    email: "admin@amc.seoul.kr"
  }
]

hospitals = []

hospital_data.each_with_index do |data, index|
  # Create hospital user
  user = User.create!(
    name: data[:name],
    email: data[:email],
    phone: "010-#{(1000 + index).to_s}-#{(1000 + index * 2).to_s}",
    password: "password123",
    password_confirmation: "password123",
    role: :hospital
  )

  # Create hospital
  hospital = Hospital.create!(
    user: user,
    name: data[:name],
    address: data[:address],
    phone: data[:phone],
    description: "#{data[:name]}은 최신 치과 의료 장비와 전문 의료진을 보유한 종합 치과병원입니다."
  )

  hospitals << hospital
  puts "Created hospital: #{hospital.name}"
end

# Create job postings
puts "Creating job postings..."

job_titles = [
  "치과위생사 (정규직)",
  "치과위생사 (파트타임)",
  "치과의사 (대타)",
  "치과기공사",
  "치과위생사 (야간)",
  "치과의사 (주말)",
  "치과위생사 (긴급대타)",
  "치과간호조무사",
  "치과의사 (임플란트 전문)",
  "치과위생사 (교정 전문)"
]

descriptions = [
  "환자 진료 보조 및 구강 보건 교육을 담당하실 치과위생사를 모집합니다. 경력 1년 이상 우대하며, 친절하고 성실한 분을 찾습니다.",
  "스케일링, 불소도포 등 예방 치료를 담당하실 위생사분을 모집합니다. 신입도 환영하며 체계적인 교육을 제공합니다.",
  "갑작스런 휴가로 인한 대타 치과의사를 모집합니다. 일반 진료 가능하신 분이면 됩니다.",
  "보철물 제작 및 수리 업무를 담당하실 치과기공사를 모집합니다. CAD/CAM 경험자 우대합니다.",
  "야간 응급 환자 대응을 위한 치과위생사를 모집합니다. 야간 수당 별도 지급됩니다.",
  "주말 진료를 위한 치과의사를 모집합니다. 주말 근무 수당 추가 지급됩니다.",
  "긴급히 대타가 필요한 상황입니다. 즉시 근무 가능하신 치과위생사분을 모집합니다.",
  "원무 업무 및 간단한 진료 보조를 담당하실 간호조무사를 모집합니다.",
  "임플란트 수술 및 보철 치료 전문 치과의사를 모집합니다. 관련 경력 3년 이상 필수입니다.",
  "교정 치료 전담 치과위생사를 모집합니다. 교정 경험자 우대하며 교육 지원 가능합니다."
]

# Create jobs for today and upcoming days
dates = [
  Date.current,
  Date.current + 1.day,
  Date.current + 2.days,
  Date.current + 3.days,
  Date.current + 1.week,
  Date.current + 2.weeks
]

hospitals.each do |hospital|
  # Each hospital creates 3-5 jobs
  rand(3..5).times do |i|
    work_date = dates.sample
    start_hour = [8, 9, 10, 14, 18].sample
    duration = [4, 6, 8].sample
    end_hour = start_hour + duration
    
    # Ensure end hour doesn't exceed 23
    end_hour = 22 if end_hour > 22
    
    Job.create!(
      hospital: hospital,
      title: job_titles.sample,
      description: descriptions.sample,
      hourly_rate: [45000, 50000, 55000, 60000, 65000, 70000, 80000, 90000, 100000].sample,
      work_date: work_date,
      start_time: Time.current.change(hour: start_hour, min: 0, sec: 0),
      end_time: Time.current.change(hour: end_hour, min: 0, sec: 0),
      status: :active
    )
  end
end

# Create some urgent jobs (today and tomorrow)
puts "Creating urgent jobs..."
5.times do
  hospital = hospitals.sample
  work_date = [Date.current, Date.tomorrow].sample
  start_hour = [9, 14, 18].sample
  duration = [4, 6, 8].sample
  end_hour = start_hour + duration
  
  # Ensure end hour doesn't exceed 23
  end_hour = 22 if end_hour > 22
  
  Job.create!(
    hospital: hospital,
    title: "🚨 긴급대타 - #{job_titles.sample}",
    description: "갑작스런 상황으로 긴급하게 대타를 구합니다. 즉시 연락 부탁드립니다!",
    hourly_rate: [60000, 70000, 80000, 90000].sample,
    work_date: work_date,
    start_time: Time.current.change(hour: start_hour, min: 0, sec: 0),
    end_time: Time.current.change(hour: end_hour, min: 0, sec: 0),
    status: :active
  )
end

puts "Seed data creation completed!"
puts "Created #{User.where(role: :hospital).count} hospital users"
puts "Created #{Hospital.count} hospitals"
puts "Created #{Job.count} job postings"
puts "Created #{Job.where(work_date: [Date.current, Date.tomorrow]).count} urgent jobs"

# Create admin user
puts "Creating admin user..."
if AdminUser.find_by(email: 'admin@dentalnow.com').nil?
  AdminUser.create!(
    email: 'admin@dentalnow.com', 
    password: 'dentalnow123', 
    password_confirmation: 'dentalnow123'
  )
  puts "Admin user created: admin@dentalnow.com / dentalnow123"
else
  puts "Admin user already exists"
end