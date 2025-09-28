# frozen_string_literal: true
ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: "대시보드"

  content title: "DentalNow 관리자 대시보드" do
    # Summary Statistics
    columns do
      column do
        panel "📊 시스템 통계" do
          table_for [
            ["전체 사용자", User.count],
            ["구직자", User.jobseeker.count],
            ["병원", User.hospital.count],
            ["관리자", AdminUser.count]
          ] do |stat|
            column("항목") { |s| s[0] }
            column("수량") { |s| strong s[1] }
          end
        end
      end

      column do
        panel "🏥 병원 현황" do
          table_for [
            ["등록된 병원", Hospital.count],
            ["활성 구인공고", Job.active.count],
            ["오늘 구인공고", Job.where(work_date: Date.current).count],
            ["긴급 구인공고", Job.where('work_date <= ?', Date.current + 2.days).count]
          ] do |stat|
            column("항목") { |s| s[0] }
            column("수량") { |s| strong s[1] }
          end
        end
      end

      column do
        panel "🤝 매칭 현황" do
          table_for [
            ["전체 지원", Matching.count],
            ["대기 중", Matching.where(status: :applied).count],
            ["승인됨", Matching.where(status: :accepted).count],
            ["완료됨", Matching.where(status: :completed).count]
          ] do |stat|
            column("항목") { |s| s[0] }
            column("수량") { |s| strong s[1] }
          end
        end
      end
    end

    # Recent Activity
    columns do
      column do
        panel "📝 최근 구인공고" do
          table_for Job.includes(:hospital).order(created_at: :desc).limit(10) do
            column("제목") { |job| link_to job.title, admin_job_path(job) }
            column("병원") { |job| job.hospital&.name }
            column("시급") { |job| number_to_currency(job.hourly_rate, unit: "₩", precision: 0) }
            column("근무일") { |job| job.work_date&.strftime('%m/%d') }
            column("상태") { |job| status_tag job.status }
          end
        end
      end

      column do
        panel "👥 최근 가입자" do
          table_for User.order(created_at: :desc).limit(10) do
            column("이름") { |user| link_to user.name, admin_user_path(user) }
            column("이메일") { |user| user.email }
            column("역할") { |user| status_tag user.role }
            column("가입일") { |user| user.created_at.strftime('%m/%d %H:%M') }
          end
        end
      end
    end

    # Recent Matchings
    columns do
      column do
        panel "🎯 최근 매칭" do
          table_for Matching.includes(:user, job: :hospital).order(created_at: :desc).limit(10) do
            column("구직자") { |matching| matching.user.name }
            column("공고") { |matching| link_to matching.job.title, admin_job_path(matching.job) }
            column("병원") { |matching| matching.job.hospital&.name }
            column("상태") { |matching| status_tag matching.status }
            column("지원일") { |matching| matching.created_at.strftime('%m/%d') }
          end
        end
      end

      column do
        panel "🔔 최근 알림" do
          table_for Notification.includes(:user).order(created_at: :desc).limit(10) do
            column("사용자") { |notification| notification.user.name }
            column("제목") { |notification| notification.title }
            column("타입") { |notification| status_tag notification.notification_type }
            column("읽음") { |notification| notification.read? ? "✓" : "✗" }
            column("생성일") { |notification| notification.created_at.strftime('%m/%d %H:%M') }
          end
        end
      end
    end

    # Daily Statistics Chart
    columns do
      column do
        panel "📈 일별 통계 (최근 7일)" do
          div id: "daily_stats" do
            table_for (0..6).map { |i| 
              date = Date.current - i.days
              [
                date.strftime('%m/%d'),
                User.where(created_at: date.beginning_of_day..date.end_of_day).count,
                Job.where(created_at: date.beginning_of_day..date.end_of_day).count,
                Matching.where(created_at: date.beginning_of_day..date.end_of_day).count
              ]
            }.reverse do
              column("날짜") { |stat| stat[0] }
              column("신규 가입자") { |stat| stat[1] }
              column("신규 공고") { |stat| stat[2] }
              column("신규 지원") { |stat| stat[3] }
            end
          end
        end
      end
    end
  end # content
end
