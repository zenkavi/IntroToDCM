function RMSE = get_rmse(True_A, Est_A)

    vect_len = size(True_A, 1)^2;
    true_vect = reshape(True_A, 1, vect_len);
    est_vect = reshape(Est_A, 1, vect_len);
    diff_vect = true_vect - est_vect;
    RMSE = sqrt(mean(diff_vect.^2));

end
